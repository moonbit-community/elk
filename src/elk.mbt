// src/layered.mbt：ELK 所有核心类型与 Layered 算法唯一实现文件，便于 Moonbit 识别

// 类型定义
///|
pub type ElkLabel = (String, Float, Float) // (text, x, y)

///|
pub type ElkPort = (String, String?, Float, Float, Float, Float) // (id, label, x, y, width, height)

///|
pub type ElkEdge = (String, String, String, @list.T[ElkLabel]) // (id, source, target, labels)

///|
pub type ElkNode = (
  String,
  String?,
  @list.T[ElkPort],
  @list.T[ElkEdge],
  Float,
  Float,
  Float,
  Float,
) // (id, label, ports, edges, x, y, width, height)

// 布局方向枚举（使用String表示）

///|
pub type LayoutDirection = String // "UP", "DOWN", "LEFT", "RIGHT"

// 节点排序策略枚举（使用String表示）

///|
pub type NodeSortingStrategy = String // "NONE", "INPUT_ORDER", "DEGREE", "NAME"

// 边缘路由策略枚举（使用String表示）

///|
pub type EdgeRoutingStrategy = String // "STRAIGHT", "ORTHOGONAL", "POLYLINE", "SPLINES"

// 对齐方式枚举（使用String表示）

///|
pub type Alignment = String // "TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER", "NONE"

// Layered 布局参数结构体（扩展版本）

///|
pub type LayeredOptions = (
  Float, // layer_spacing: 层间距
  Float, // node_spacing: 节点间距
  LayoutDirection, // direction: 布局方向
  NodeSortingStrategy, // node_sorting: 节点排序策略
  EdgeRoutingStrategy, // edge_routing: 边缘路由策略
  Alignment, // alignment: 节点对齐方式
  Bool, // consider_node_labels: 是否考虑节点标签
  Bool, // consider_port_positions: 是否考虑端口位置
  Float, // aspect_ratio: 布局的宽高比
  Int, // iterations: 布局算法迭代次数
)

// 布局算法类型

///|
pub type LayoutAlgorithm = String // "layered" | "fixed" | "force" 等

// 通用布局参数（目前只支持 LayeredOptions，后续可扩展）

///|
pub type LayoutOptions = (LayoutAlgorithm, LayeredOptions)

// 边缘交叉最小化相关类型

///|
pub type EdgePair = (String, String) // (source, target)

///|
pub type Position = (Float, Float) // (x, y)

///|
pub type NodePosition = (String, Position) // (node_id, position)

// 增量布局状态

///|
pub type LayoutState = (
  @hashmap.T[String, ElkNode], // 节点映射
  @hashmap.T[String, Int], // 层映射
  @hashmap.T[Int, @list.T[String]], // 层到节点列表映射
  @hashmap.T[String, Position], // 节点位置映射
)

// 创建默认的LayeredOptions

///|
pub fn default_layered_options() -> LayeredOptions {
  (
    50.0, // layer_spacing
     30.0, // node_spacing
     "DOWN", // direction
     "INPUT_ORDER", // node_sorting
     "STRAIGHT", // edge_routing
     "CENTER", // alignment
     true, // consider_node_labels
     true, // consider_port_positions
     1.0, // aspect_ratio
     10, // iterations
  )
}

// 递归遍历所有节点，构建 id -> ElkNode 映射

///|
fn visit_edges(
  node : ElkNode,
  acc : @hashmap.T[String, ElkNode],
) -> @hashmap.T[String, ElkNode] {
  // 防止死循环：已访问过则直接返回
  if acc.contains(node.0) {
    acc
  } else {
    acc.set(node.0, node)
    match node.3 {
      [] => acc
      [edge, ..rest] => {
        let target_node_opt = acc.get(edge.1)
        let acc2 = match target_node_opt {
          Some(target_node) => visit(target_node, acc)
          None => acc
        }
        let node_rest = (
          node.0,
          node.1,
          node.2,
          rest,
          node.4,
          node.5,
          node.6,
          node.7,
        )
        visit_edges(node_rest, acc2)
      }
    }
  }
}

///|
fn visit(
  node : ElkNode,
  acc : @hashmap.T[String, ElkNode],
) -> @hashmap.T[String, ElkNode] {
  visit_edges(node, acc)
}

///|
fn build_node_map(root : ElkNode) -> @hashmap.T[String, ElkNode] {
  let map = @hashmap.new()
  visit(root, map)
}

// 辅助：递归BFS分层，支持查找表

///|
fn add_children(
  edges : @list.T[ElkEdge],
  q : @list.T[(ElkNode, Int)],
  node_map : @hashmap.T[String, ElkNode],
  next_layer : Int,
) -> @list.T[(ElkNode, Int)] {
  match edges {
    [] => q
    [edge, ..rest_edges] => {
      let target_node_opt = node_map.get(edge.1)
      match target_node_opt {
        Some(target_node) =>
          add_children(
            rest_edges,
            [(target_node, ..next_layer], q),
            node_map,
            next_layer,
          )
        None => add_children(rest_edges, q, node_map, next_layer)
      }
    }
  }
}

///|
fn bfs(
  queue : @list.T[(ElkNode, Int)],
  layer_map : @hashmap.T[String, Int],
  node_map : @hashmap.T[String, ElkNode],
) -> @hashmap.T[String, Int] {
  match queue {
    [] => layer_map
    [(node, ..layer], rest) =>
      if layer_map.contains(node.0) {
        bfs(rest, layer_map, node_map)
      } else {
        layer_map.set(node.0, layer)
        let queue2 = add_children(node.3, rest, node_map, layer + 1)
        bfs(queue2, layer_map, node_map)
      }
  }
}

///|
fn assign_layers(root : ElkNode) -> @hashmap.T[String, Int] {
  let node_map = build_node_map(root)
  let layer_map = @hashmap.new()
  bfs([(root, ..0], Nil), layer_map, node_map)
}

// 边缘交叉最小化算法

///|
pub fn minimize_crossings(
  layers : @hashmap.T[Int, @list.T[String]],
  edges : @list.T[ElkEdge],
) -> @hashmap.T[Int, @list.T[String]] {
  let mut i = 0
  while i < layers.size() - 1 {
    let layer1_opt = layers.get(i)
    let layer2_opt = layers.get(i + 1)
    match (layer1_opt, layer2_opt) {
      (Some(layer1), Some(layer2)) => {
        let crossings1 = count_crossings(layer1, layer2, edges)
        let layer1_reversed = reverse_list(layer1)
        let crossings2 = count_crossings(layer1_reversed, layer2, edges)
        if crossings2 < crossings1 {
          layers.set(i, layer1_reversed)
        }
      }
      _ => ()
    }
    i = i + 1
  }
  layers
}

///|
pub fn count_crossings(
  layer1 : @list.T[String],
  layer2 : @list.T[String],
  edges : @list.T[ElkEdge],
) -> Int {
  let mut crossings = 0
  let mut i = 0
  while i < list_length(layer1) {
    let mut j = i + 1
    while j < list_length(layer1) {
      let node1_i = get_node_at_index(layer1, i)
      let node1_j = get_node_at_index(layer1, j)
      let mut k = 0
      while k < list_length(layer2) {
        let mut l = k + 1
        while l < list_length(layer2) {
          let node2_k = get_node_at_index(layer2, k)
          let node2_l = get_node_at_index(layer2, l)
          if has_edge_between(node1_i, node2_k, edges) &&
            has_edge_between(node1_j, node2_l, edges) {
            if (i < j && k > l) || (i > j && k < l) {
              crossings = crossings + 1
            }
          }
          l = l + 1
        }
        k = k + 1
      }
      j = j + 1
    }
    i = i + 1
  }
  crossings
}

///|
pub fn get_node_at_index(nodes : @list.T[String], index : Int) -> String {
  let mut current = nodes
  let mut i = 0
  while i < index {
    match current {
      [_, ..rest] => current = rest
      [] => break
    }
    i = i + 1
  }
  match current {
    [node, .._] => node
    [] => ""
  }
}

///|
pub fn has_edge_between(
  source : String,
  target : String,
  edges : @list.T[ElkEdge],
) -> Bool {
  let mut current = edges
  while true {
    match current {
      [edge, ..rest] => {
        if edge.1 == source && edge.2 == target {
          return true
        }
        current = rest
      }
      [] => return false
    }
  }
  false
}

///|
pub fn[T] reverse_list(lst : @list.T[T]) -> @list.T[T] {
  let mut result = Nil
  let mut current = lst
  while true {
    match current {
      [head, ..rest] => {
        result = [head, ..result]
        current = rest
      }
      [] => break
    }
  }
  result
}

// 按指定策略对节点进行排序

///|
fn sort_nodes(
  ids : @list.T[String],
  strategy : NodeSortingStrategy,
  node_map : @hashmap.T[String, ElkNode],
) -> @list.T[String] {
  match strategy {
    "NONE" => ids // 不排序，保持原始顺序
    "INPUT_ORDER" => ids // 按输入顺序，与NONE相同
    "NAME" => sort_nodes_by_name(ids, Nil) // 按名称字母顺序排序
    "DEGREE" => sort_nodes_by_degree(ids, node_map, Nil) // 按度数（连接数）排序
    _ => ids // 默认不排序
  }
}

///|
pub fn sort_nodes_by_name(
  ids : @list.T[String],
  result : @list.T[String],
) -> @list.T[String] {
  match ids {
    [] => result
    [id, ..rest] => sort_nodes_by_name(rest, insert_by_name(id, result))
  }
}

///|
pub fn insert_by_name(id : String, sorted : @list.T[String]) -> @list.T[String] {
  match sorted {
    [] => [id, ..Nil]
    [head, ..tail] =>
      if id <= head {
        [id, ..sorted]
      } else {
        [head, ..insert_by_name(id, tail])
      }
  }
}

// 计算节点的度数（连接数）

///|
pub fn node_degree(node : ElkNode) -> Int {
  list_length(node.3) // 边的数量
}

// 计算列表长度

///|
pub fn[T] list_length(lst : @list.T[T]) -> Int {
  match lst {
    [] => 0
    [_, ..rest] => 1 + list_length(rest)
  }
}

// 按度数排序节点

///|
fn sort_nodes_by_degree(
  ids : @list.T[String],
  node_map : @hashmap.T[String, ElkNode],
  result : @list.T[String],
) -> @list.T[String] {
  match ids {
    [] => result
    [id, ..rest] => {
      let node_opt = node_map.get(id)
      let degree = match node_opt {
        Some(node) => node_degree(node)
        None => 0
      }
      sort_nodes_by_degree(
        rest,
        node_map,
        insert_by_degree(id, degree, result, node_map),
      )
    }
  }
}

///|
pub fn insert_by_degree(
  id : String,
  degree : Int,
  sorted : @list.T[String],
  node_map : @hashmap.T[String, ElkNode],
) -> @list.T[String] {
  match sorted {
    [] => [id, ..Nil]
    [head, ..tail] => {
      let head_node_opt = node_map.get(head)
      let head_degree = match head_node_opt {
        Some(node) => node_degree(node)
        None => 0
      }
      if degree >= head_degree { // 度数大的排在前面
        [id, ..sorted]
      } else {
        [head, ..insert_by_degree(id, degree, tail, node_map])
      }
    }
  }
}

///|
pub fn group_layers(
  keys : @list.T[String],
  map : @hashmap.T[String, Int],
  layers : @hashmap.T[Int, @list.T[String]],
  node_map : @hashmap.T[String, ElkNode],
  options : LayeredOptions,
) -> @hashmap.T[Int, @list.T[String]] {
  match keys {
    [] => layers
    [id, ..rest] => {
      let layer_opt = map.get(id)
      match layer_opt {
        Some(layer) => {
          let old = match layers.get(layer) {
            Some(v) => v
            None => Nil
          }
          layers.set(layer, [id, ..old])
          group_layers(rest, map, layers, node_map, options)
        }
        None => group_layers(rest, map, layers, node_map, options)
      }
    }
  }
}

// 根据对齐方式计算X坐标

///|
fn calculate_x_by_alignment(
  alignment : Alignment,
  x : Float,
  width : Float,
  node_width : Float,
) -> Float {
  match alignment {
    "LEFT" => x
    "CENTER" => x + (width - node_width) / 2.0
    "RIGHT" => x + width - node_width
    _ => x // 默认左对齐
  }
}

///|
pub fn assign_x(
  ids : @list.T[String],
  x : Float,
  node_spacing : Float,
  node_map : @hashmap.T[String, ElkNode],
  alignment : Alignment,
  max_width : Float,
) -> Float {
  match ids {
    [] => x
    [id, ..rest_ids] => {
      let node_opt = node_map.get(id)
      let node_width = match node_opt {
        Some(node) => node.6
        None => 0.0
      }
      let _ = calculate_x_by_alignment(alignment, x, max_width, node_width)
      assign_x(
        rest_ids,
        x + node_spacing + node_width,
        node_spacing,
        node_map,
        alignment,
        max_width,
      )
    }
  }
}

// 计算层中最大节点宽度

///|
pub fn calculate_max_width(
  ids : @list.T[String],
  node_map : @hashmap.T[String, ElkNode],
  max : Float,
) -> Float {
  match ids {
    [] => max
    [id, ..rest] => {
      let node_opt = node_map.get(id)
      let width = match node_opt {
        Some(node) => node.6
        None => 0.0
      }
      calculate_max_width(rest, node_map, if width > max { width } else { max })
    }
  }
}

///|
pub fn assign_coords(
  layers : @hashmap.T[Int, @list.T[String]],
  _y : Float,
  options : LayeredOptions,
  node_map : @hashmap.T[String, ElkNode],
) -> Unit {
  // 遍历所有层
  let mut i = 0
  while i < layers.size() {
    let layer_opt : @list.T[String]? = layers.get(i)
    match layer_opt {
      Some(ids) => {
        // 按指定策略排序节点
        let sorted_ids = sort_nodes(ids, options.3, node_map)

        // 计算层中最大节点宽度（用于对齐）
        let max_width = calculate_max_width(sorted_ids, node_map, 0.0)
        let x : Float = 0.0
        let _ = assign_x(
          sorted_ids,
          x,
          options.1,
          node_map,
          options.5,
          max_width,
        )

      }
      None => ()
    }
    i = i + 1
  }
}

// 提取所有 id（顶层函数）

///|
pub fn collect_ids(map : @hashmap.T[String, Int]) -> @list.T[String] {
  let mut result = Nil
  map.each((k, _) => result = [k, ..result])
  result
}

// 边缘路由算法

///|
pub fn route_edge(
  source : String,
  target : String,
  source_pos : Position,
  target_pos : Position,
  strategy : EdgeRoutingStrategy,
) -> @list.T[Position] {
  match strategy {
    "STRAIGHT" => [source_pos, ..Cons(target_pos, Nil])
    "ORTHOGONAL" => route_orthogonal(source_pos, target_pos)
    "POLYLINE" => route_polyline(source_pos, target_pos)
    "SPLINES" => route_splines(source_pos, target_pos)
    _ => [source_pos, ..Cons(target_pos, Nil])
  }
}

///|
fn route_orthogonal(source : Position, target : Position) -> @list.T[Position] {
  let (sx, sy) = source
  let (tx, ty) = target
  let mid_x : Float = (sx + tx) / 2.0
  let mid_y : Float = (sy + ty) / 2.0
  [
    source, ..Cons(
      (mid_x, sy],
      [(mid_x, ..ty], [target, ..Nil]),
    ),
  )
}

///|
fn route_polyline(source : Position, target : Position) -> @list.T[Position] {
  let (sx, sy) = source
  let (tx, ty) = target
  let mid_x : Float = (sx + tx) / 2.0
  let mid_y : Float = (sy + ty) / 2.0
  [source, ..Cons((mid_x, mid_y], [target, ..Nil]))
}

///|
fn route_splines(source : Position, target : Position) -> @list.T[Position] {
  // 简化的样条曲线实现，使用多个控制点
  let (sx, sy) = source
  let (tx, ty) = target
  let ctrl1_x : Float = sx + (tx - sx) * 0.25
  let ctrl1_y : Float = sy
  let ctrl2_x : Float = sx + (tx - sx) * 0.75
  let ctrl2_y : Float = ty
  [
    source, ..Cons(
      (ctrl1_x, ctrl1_y],
      [(ctrl2_x, ..ctrl2_y], [target, ..Nil]),
    ),
  )
}

// 增量式布局功能

///|
fn create_layout_state() -> LayoutState {
  (
    @hashmap.new(), // 节点映射
    @hashmap.new(), // 层映射
    @hashmap.new(), // 层到节点列表映射
    @hashmap.new(), // 节点位置映射
  )
}

///|
fn add_node_to_layout(
  state : LayoutState,
  node : ElkNode,
  layer : Int,
) -> LayoutState {
  let (node_map, layer_map, layer_nodes, positions) = state
  node_map.set(node.0, node)
  layer_map.set(node.0, layer)
  let existing_nodes = match layer_nodes.get(layer) {
    Some(nodes) => nodes
    None => Nil
  }
  layer_nodes.set(layer, [node.0, ..existing_nodes])
  (node_map, layer_map, layer_nodes, positions)
}

///|
fn add_edge_to_layout(state : LayoutState, edge : ElkEdge) -> LayoutState {
  let (node_map, layer_map, layer_nodes, positions) = state
  // 重新计算受影响的层
  let source_layer = match layer_map.get(edge.1) {
    Some(layer) => layer
    None => 0
  }
  let target_layer = match layer_map.get(edge.2) {
    Some(layer) => layer
    None => source_layer + 1
  }

  // 更新目标节点的层
  if target_layer <= source_layer {
    layer_map.set(edge.2, source_layer + 1)
    // 重新分配目标节点到新层
    let old_layer_nodes = match layer_nodes.get(target_layer) {
      Some(nodes) => remove_node_from_list(nodes, edge.2)
      None => Nil
    }
    layer_nodes.set(target_layer, old_layer_nodes)
    let new_layer_nodes = match layer_nodes.get(source_layer + 1) {
      Some(nodes) => [edge.2, ..nodes]
      None => [edge.2, ..Nil]
    }
    layer_nodes.set(source_layer + 1, new_layer_nodes)
  }
  (node_map, layer_map, layer_nodes, positions)
}

///|
pub fn remove_node_from_list(
  nodes : @list.T[String],
  node_id : String,
) -> @list.T[String] {
  let mut result = Nil
  let mut current = nodes
  while true {
    match current {
      [head, ..rest] => {
        if head != node_id {
          result = [head, ..result]
        }
        current = rest
      }
      [] => break
    }
  }
  reverse_list(result)
}

///|
fn update_layout_positions(
  state : LayoutState,
  options : LayeredOptions,
) -> LayoutState {
  let (node_map, layer_map, layer_nodes, _positions) = state

  // 重新计算所有节点的位置
  let mut layer_index = 0
  let mut y_pos : Float = 0.0
  let new_positions = @hashmap.new()
  while layer_index < layer_nodes.size() {
    let layer_nodes_opt = layer_nodes.get(layer_index)
    match layer_nodes_opt {
      Some(nodes) => {
        let sorted_nodes = sort_nodes(nodes, options.3, node_map)
        let mut x_pos : Float = 0.0
        let mut node_index = 0
        while node_index < list_length(sorted_nodes) {
          let node_id = get_node_at_index(sorted_nodes, node_index)
          new_positions.set(node_id, (x_pos, y_pos))
          x_pos = x_pos + options.1 + 50.0 // node_spacing + default width
          node_index = node_index + 1
        }
        y_pos = y_pos + options.0 // layer_spacing
      }
      None => ()
    }
    layer_index = layer_index + 1
  }
  (node_map, layer_map, layer_nodes, new_positions)
}

// Layered 布局主入口

///|
pub fn layout_layered(root : ElkNode, options : LayeredOptions) -> ElkNode {
  // 1. 分层
  let layer_map = assign_layers(root)

  // 2. 构建节点映射
  let node_map = build_node_map(root)

  // 3. 按层分组
  let keys = collect_ids(layer_map)
  let layers = @hashmap.new()
  let grouped_layers = group_layers(keys, layer_map, layers, node_map, options)

  // 4. 边缘交叉最小化
  let all_edges = collect_all_edges(node_map)
  let optimized_layers = minimize_crossings(grouped_layers, all_edges)

  // 5. 坐标分配
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = root.6
  let h : Float = root.7
  let result : ElkNode = (root.0, root.1, root.2, root.3, x, y, w, h)

  // 应用布局配置进行坐标分配
  assign_coords(optimized_layers, options.0, options, node_map)
  result
}

///|
pub fn collect_all_edges(
  node_map : @hashmap.T[String, ElkNode],
) -> @list.T[ElkEdge] {
  let mut all_edges = Nil
  node_map.each((_, node) => all_edges = append_edges(all_edges, node.3))
  all_edges
}

///|
pub fn append_edges(
  edges1 : @list.T[ElkEdge],
  edges2 : @list.T[ElkEdge],
) -> @list.T[ElkEdge] {
  match edges1 {
    [] => edges2
    [head, ..rest] => [head, ..append_edges(rest, edges2])
  }
}

// Fixed 布局算法（示例：直接返回输入，不做布局）

///|
pub fn layout_fixed(root : ElkNode, _options : LayeredOptions) -> ElkNode {
  // 固定布局：直接返回原始节点
  root
}

// Force-directed 布局算法相关顶层函数

///|
pub fn force_init_pos(
  ids : @list.T[String],
  acc : @hashmap.T[String, (Float, Float)],
) -> @hashmap.T[String, (Float, Float)] {
  match ids {
    [] => acc
    [id, ..rest] => {
      acc.set(id, (0.0, 0.0))
      force_init_pos(rest, acc)
    }
  }
}

///|
pub fn force_calc_repulsion(
  ids : @list.T[String],
  pos : @hashmap.T[String, (Float, Float)],
  k : Float,
  acc : @hashmap.T[String, (Float, Float)],
) -> @hashmap.T[String, (Float, Float)] {
  match ids {
    [] => acc
    [id, ..rest] => {
      let pos_opt = pos.get(id)
      let (x, y) = match pos_opt {
        Some((x, y)) => (x, y)
        None => (0.0, 0.0)
      }
      let (fx, fy) = force_sum_rep(ids, id, x, y, pos, k, ids, 0.0, 0.0)
      acc.set(id, (fx, fy))
      force_calc_repulsion(rest, pos, k, acc)
    }
  }
}

///|
fn force_sum_rep(
  ids : @list.T[String],
  id : String,
  x : Float,
  y : Float,
  pos : @hashmap.T[String, (Float, Float)],
  k : Float,
  ids2 : @list.T[String],
  fx : Float,
  fy : Float,
) -> (Float, Float) {
  match ids2 {
    [] => (fx, fy)
    [id2, ..rest2] =>
      if id == id2 {
        force_sum_rep(ids, id, x, y, pos, k, rest2, fx, fy)
      } else {
        let pos_opt = pos.get(id2)
        let (x2, y2) = match pos_opt {
          Some((x, y)) => (x, y)
          None => (0.0, 0.0)
        }
        let dx = x - x2
        let dy = y - y2
        let dist = (dx * dx + dy * dy).sqrt() + 0.01
        let force = k * k / dist
        force_sum_rep(
          ids,
          id,
          x,
          y,
          pos,
          k,
          rest2,
          fx + dx / dist * force,
          fy + dy / dist * force,
        )
      }
  }
}

///|
fn force_append_edges(
  edges : @list.T[ElkEdge],
  acc : @list.T[ElkEdge],
) -> @list.T[ElkEdge] {
  match edges {
    [] => acc
    [e, ..rest] => force_append_edges(rest, [e, ..acc])
  }
}

///|
pub fn force_edges_for(
  map : @hashmap.T[String, ElkNode],
  acc : @list.T[ElkEdge],
) -> @list.T[ElkEdge] {
  let mut result = acc
  map.each((_, node) => result = force_append_edges(node.3, result))
  result
}

///|
fn force_sum_att(
  edges : @list.T[ElkEdge],
  pos : @hashmap.T[String, (Float, Float)],
  k : Float,
  acc2 : @hashmap.T[String, (Float, Float)],
) -> @hashmap.T[String, (Float, Float)] {
  match edges {
    [] => acc2
    [e, ..rest] => {
      let (src, tgt) = (e.1, e.2)
      let src_pos_opt = pos.get(src)
      let tgt_pos_opt = pos.get(tgt)
      let (x1, y1) = match src_pos_opt {
        Some((x, y)) => (x, y)
        None => (0.0, 0.0)
      }
      let (x2, y2) = match tgt_pos_opt {
        Some((x, y)) => (x, y)
        None => (0.0, 0.0)
      }
      let dx = x2 - x1
      let dy = y2 - y1
      let dist = (dx * dx + dy * dy).sqrt() + 0.01
      let force = dist * dist / k
      let fx = dx / dist * force
      let fy = dy / dist * force
      // 更新源节点的力
      let src_force_opt = acc2.get(src)
      let (src_fx, src_fy) = match src_force_opt {
        Some((fx, fy)) => (fx, fy)
        None => (0.0, 0.0)
      }
      acc2.set(src, (src_fx + fx, src_fy + fy))
      // 更新目标节点的力
      let tgt_force_opt = acc2.get(tgt)
      let (tgt_fx, tgt_fy) = match tgt_force_opt {
        Some((fx, fy)) => (fx, fy)
        None => (0.0, 0.0)
      }
      acc2.set(tgt, (tgt_fx - fx, tgt_fy - fy))
      force_sum_att(rest, pos, k, acc2)
    }
  }
}

///|
pub fn force_calc_attraction(
  node_map : @hashmap.T[String, ElkNode],
  pos : @hashmap.T[String, (Float, Float)],
  k : Float,
  acc : @hashmap.T[String, (Float, Float)],
) -> @hashmap.T[String, (Float, Float)] {
  let all_edges = force_edges_for(node_map, Nil)
  force_sum_att(all_edges, pos, k, acc)
}

///|
pub fn force_iterate(
  pos : @hashmap.T[String, (Float, Float)],
  ids : @list.T[String],
  node_map : @hashmap.T[String, ElkNode],
  k : Float,
  cool : Float,
  iter : Int,
) -> @hashmap.T[String, (Float, Float)] {
  if iter == 0 {
    pos
  } else {
    let rep = @hashmap.new()
    let rep_forces = force_calc_repulsion(ids, pos, k, rep)
    let att = @hashmap.new()
    let att_forces = force_calc_attraction(node_map, pos, k, att)
    let new_pos = @hashmap.new()
    let updated_pos = force_update(
      ids, pos, rep_forces, att_forces, cool, iter, new_pos,
    )
    force_iterate(updated_pos, ids, node_map, k, cool, iter - 1)
  }
}

///|
pub fn force_update(
  ids : @list.T[String],
  pos : @hashmap.T[String, (Float, Float)],
  rep : @hashmap.T[String, (Float, Float)],
  att : @hashmap.T[String, (Float, Float)],
  cool : Float,
  iter : Int,
  acc : @hashmap.T[String, (Float, Float)],
) -> @hashmap.T[String, (Float, Float)] {
  match ids {
    [] => acc
    [id, ..rest] => {
      let pos_opt = pos.get(id)
      let (x, y) = match pos_opt {
        Some((x, y)) => (x, y)
        None => (0.0, 0.0)
      }
      let rep_opt = rep.get(id)
      let (rfx, rfy) = match rep_opt {
        Some((fx, fy)) => (fx, fy)
        None => (0.0, 0.0)
      }
      let att_opt = att.get(id)
      let (afx, afy) = match att_opt {
        Some((fx, fy)) => (fx, fy)
        None => (0.0, 0.0)
      }
      let fx = rfx + afx
      let fy = rfy + afy
      let nx = x + fx * cool / to_float(iter)
      let ny = y + fy * cool / to_float(iter)
      acc.set(id, (nx, ny))
      force_update(rest, pos, rep, att, cool, iter, acc)
    }
  }
}

///|
pub fn force_update_node(
  node : ElkNode,
  pos : @hashmap.T[String, (Float, Float)],
) -> ElkNode {
  let pos_opt = pos.get(node.0)
  let (x, y) = match pos_opt {
    Some((x, y)) => (x, y)
    None => (0.0, 0.0)
  }
  let result : ElkNode = (node.0, node.1, node.2, node.3, x, y, node.6, node.7)
  result
}

// 收集所有节点 id（force 算法专用）

///|
pub fn collect_node_ids(map : @hashmap.T[String, ElkNode]) -> @list.T[String] {
  let mut result = Nil
  map.each((id, _) => result = [id, ..result])
  result
}

// 去掉所有 as Float，直接用变量本身。修正 to_float 为 i * 1.0。

///|
pub fn to_float(i : Int) -> Float {
  i.to_float()
}

// Force-directed 布局主入口（使用扩展的LayeredOptions）

///|
pub fn layout_force(root : ElkNode, options : LayeredOptions) -> ElkNode {
  let node_map = build_node_map(root)
  let ids = collect_node_ids(node_map)
  let pos = @hashmap.new()
  let init_pos = force_init_pos(ids, pos)

  // 使用配置的迭代次数
  let iterations = options.9

  // 使用配置的宽高比调整力常数
  let k : Float = 50.0 * options.8
  let cool : Float = 0.9
  let final_pos = force_iterate(init_pos, ids, node_map, k, cool, iterations)
  force_update_node(root, final_pos)
}

// 增量式布局 API

///|
pub fn incremental_layout_add_node(
  state : LayoutState,
  node : ElkNode,
  layer : Int,
) -> LayoutState {
  add_node_to_layout(state, node, layer)
}

///|
pub fn incremental_layout_add_edge(
  state : LayoutState,
  edge : ElkEdge,
) -> LayoutState {
  add_edge_to_layout(state, edge)
}

///|
pub fn incremental_layout_update(
  state : LayoutState,
  options : LayeredOptions,
) -> LayoutState {
  update_layout_positions(state, options)
}

///|
pub fn incremental_layout_get_positions(
  state : LayoutState,
) -> @hashmap.T[String, Position] {
  let (_, _, _, positions) = state
  positions
}

///|
/// 通用布局 API，根据算法类型分发
pub fn elk_layout(root : ElkNode, options : LayoutOptions) -> ElkNode {
  match options.0 {
    "layered" => layout_layered(root, options.1)
    "fixed" => layout_fixed(root, options.1)
    "force" => layout_force(root, options.1)
    _ => layout_layered(root, options.1) // 默认用 layered
  }
}
