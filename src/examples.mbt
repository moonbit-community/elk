// examples.mbt: ELK 布局库使用示例

// 示例1: 基本分层布局
///|
pub fn example_basic_layered() -> ElkNode {
  // 创建简单的图结构：A -> B -> C
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeC : ElkNode = (
    "C",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @immut/list.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @immut/list.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Cons(edgeAB, @immut/list.Nil),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  layout_layered(root, options)
}

// 示例2: 复杂多层图布局

///|
pub fn example_complex_multilayer() -> ElkNode {
  // 创建复杂多层图：A -> B,C -> D,E,F -> G
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = (
    "A",
    Some("Start"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    Some("Process1"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeC : ElkNode = (
    "C",
    Some("Process2"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeD : ElkNode = (
    "D",
    Some("Sub1"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeE : ElkNode = (
    "E",
    Some("Sub2"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeF : ElkNode = (
    "F",
    Some("Sub3"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeG : ElkNode = (
    "G",
    Some("End"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @immut/list.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @immut/list.Nil)
  let edgeBD : ElkEdge = ("e3", "B", "D", @immut/list.Nil)
  let edgeBE : ElkEdge = ("e4", "B", "E", @immut/list.Nil)
  let edgeCD : ElkEdge = ("e5", "C", "D", @immut/list.Nil)
  let edgeCF : ElkEdge = ("e6", "C", "F", @immut/list.Nil)
  let edgeDG : ElkEdge = ("e7", "D", "G", @immut/list.Nil)
  let edgeEG : ElkEdge = ("e8", "E", "G", @immut/list.Nil)
  let edgeFG : ElkEdge = ("e9", "F", "G", @immut/list.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Start"),
    @immut/list.Nil,
    @immut/list.Cons(edgeAB, @immut/list.Cons(edgeAC, @immut/list.Nil)),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges

  // 使用自定义选项
  let custom_options : LayeredOptions = (
    60.0, // layer_spacing: 更大的层间距
     40.0, // node_spacing: 更大的节点间距
     "DOWN", // direction: 向下布局
     "DEGREE", // node_sorting: 按度数排序
     "ORTHOGONAL", // edge_routing: 正交边缘路由
     "CENTER", // alignment: 居中对齐
     true, // consider_node_labels: 考虑节点标签
     true, // consider_port_positions: 考虑端口位置
     1.2, // aspect_ratio: 稍微宽一些的宽高比
     20, // iterations: 更多迭代次数
  )
  layout_layered(root, custom_options)
}

// 示例3: 带标签和端口的图

///|
pub fn example_with_labels_and_ports() -> ElkNode {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建带标签的节点
  let nodeA : ElkNode = (
    "A",
    Some("Input"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    Some("Process"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeC : ElkNode = (
    "C",
    Some("Output"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )

  // 创建带标签的边
  let label1 : ElkLabel = ("data", 0.0, 0.0)
  let label2 : ElkLabel = ("result", 0.0, 0.0)
  let edgeAB : ElkEdge = (
    "e1",
    "A",
    "B",
    @immut/list.Cons(label1, @immut/list.Nil),
  )
  let edgeBC : ElkEdge = (
    "e2",
    "B",
    "C",
    @immut/list.Cons(label2, @immut/list.Nil),
  )
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Input"),
    @immut/list.Nil,
    @immut/list.Cons(edgeAB, @immut/list.Nil),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  layout_layered(root, options)
}

// 示例4: Force布局算法

///|
pub fn example_force_layout() -> ElkNode {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建用于Force布局的图（无向图）
  let nodeA : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeC : ElkNode = (
    "C",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeD : ElkNode = (
    "D",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @immut/list.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @immut/list.Nil)
  let edgeCD : ElkEdge = ("e3", "C", "D", @immut/list.Nil)
  let edgeAD : ElkEdge = ("e4", "A", "D", @immut/list.Nil)
  let edgeAC : ElkEdge = ("e5", "A", "C", @immut/list.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Cons(
      edgeAB,
      @immut/list.Cons(edgeAD, @immut/list.Cons(edgeAC, @immut/list.Nil)),
    ),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  layout_force(root, options)
}

// 示例5: 增量式布局

///|
pub fn example_incremental_layout() -> LayoutState {
  // 创建初始布局状态
  let initial_state = (
    @hashmap.new(), // 节点映射
    @hashmap.new(), // 层映射
    @hashmap.new(), // 层到节点列表映射
    @hashmap.new(), // 节点位置映射
  )
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 逐步添加节点
  let nodeA : ElkNode = (
    "A",
    Some("Start"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : ElkNode = (
    "B",
    Some("Process"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let state2 = incremental_layout_add_node(state1, nodeB, 1)
  let nodeC : ElkNode = (
    "C",
    Some("End"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let state3 = incremental_layout_add_node(state2, nodeC, 2)

  // 添加边
  let edgeAB : ElkEdge = ("e1", "A", "B", @immut/list.Nil)
  let state4 = incremental_layout_add_edge(state3, edgeAB)
  let edgeBC : ElkEdge = ("e2", "B", "C", @immut/list.Nil)
  let state5 = incremental_layout_add_edge(state4, edgeBC)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  incremental_layout_update(state5, options)
}

// 示例6: 不同布局方向

///|
pub fn example_different_directions() -> @immut/list.T[ElkNode] {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @immut/list.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Cons(edgeAB, @immut/list.Nil),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges

  // 测试不同方向
  let directions = @immut/list.Cons(
    "DOWN",
    @immut/list.Cons(
      "UP",
      @immut/list.Cons("LEFT", @immut/list.Cons("RIGHT", @immut/list.Nil)),
    ),
  )
  let mut results = @immut/list.Nil
  let mut current = directions
  while true {
    match current {
      @immut/list.Cons(direction, rest) => {
        let options : LayeredOptions = (
          50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true,
          1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
        results = @immut/list.Cons(result, results)
        current = rest
      }
      @immut/list.Nil => break
    }
  }
  results
}

// 示例7: 边缘路由演示

///|
pub fn example_edge_routing() -> @immut/list.T[@immut/list.T[Position]] {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试所有边缘路由策略
  let strategies = @immut/list.Cons(
    "STRAIGHT",
    @immut/list.Cons(
      "ORTHOGONAL",
      @immut/list.Cons("POLYLINE", @immut/list.Cons("SPLINES", @immut/list.Nil)),
    ),
  )
  let mut routes = @immut/list.Nil
  let mut current = strategies
  while true {
    match current {
      @immut/list.Cons(strategy, rest) => {
        let route = route_edge("A", "B", source_pos, target_pos, strategy)
        routes = @immut/list.Cons(route, routes)
        current = rest
      }
      @immut/list.Nil => break
    }
  }
  routes
}

// 示例8: 性能测试图

///|
pub fn example_performance_test() -> ElkNode {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个中等规模的图（20个节点）
  let mut edges = @immut/list.Nil
  let mut i = 0
  while i < 19 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @immut/list.Nil)
    edges = @immut/list.Cons(edge, edges)
    i = i + 1
  }

  // 添加一些交叉边
  let cross_edge1 : ElkEdge = ("cross1", "node0", "node10", @immut/list.Nil)
  let cross_edge2 : ElkEdge = ("cross2", "node5", "node15", @immut/list.Nil)
  edges = @immut/list.Cons(cross_edge1, @immut/list.Cons(cross_edge2, edges))
  let root : ElkNode = ("node0", None, @immut/list.Nil, edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  layout_layered(root, options)
}

// 示例9: 通用布局API演示

///|
pub fn example_universal_api() -> @immut/list.T[ElkNode] {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @immut/list.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @immut/list.Nil,
    @immut/list.Cons(edgeAB, @immut/list.Nil),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()

  // 使用不同算法
  let layered_options : LayoutOptions = ("layered", options)
  let layered_result : ElkNode = elk_layout(root, layered_options)
  let force_options : LayoutOptions = ("force", options)
  let force_result : ElkNode = elk_layout(root, force_options)
  let fixed_options : LayoutOptions = ("fixed", options)
  let fixed_result : ElkNode = elk_layout(root, fixed_options)
  @immut/list.Cons(
    layered_result,
    @immut/list.Cons(
      force_result,
      @immut/list.Cons(fixed_result, @immut/list.Nil),
    ),
  )
}

// 示例10: 复杂工作流图

///|
pub fn example_workflow_graph() -> ElkNode {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个工作流图：开始 -> 决策 -> 分支 -> 合并 -> 结束
  let nodeStart : ElkNode = (
    "Start",
    Some("开始"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeDecision : ElkNode = (
    "Decision",
    Some("决策"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeBranch1 : ElkNode = (
    "Branch1",
    Some("分支1"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeBranch2 : ElkNode = (
    "Branch2",
    Some("分支2"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeMerge : ElkNode = (
    "Merge",
    Some("合并"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeEnd : ElkNode = (
    "End",
    Some("结束"),
    @immut/list.Nil,
    @immut/list.Nil,
    x,
    y,
    w,
    h,
  )
  let edge1 : ElkEdge = ("e1", "Start", "Decision", @immut/list.Nil)
  let edge2 : ElkEdge = ("e2", "Decision", "Branch1", @immut/list.Nil)
  let edge3 : ElkEdge = ("e3", "Decision", "Branch2", @immut/list.Nil)
  let edge4 : ElkEdge = ("e4", "Branch1", "Merge", @immut/list.Nil)
  let edge5 : ElkEdge = ("e5", "Branch2", "Merge", @immut/list.Nil)
  let edge6 : ElkEdge = ("e6", "Merge", "End", @immut/list.Nil)
  let nodeStart_with_edges : ElkNode = (
    "Start",
    Some("开始"),
    @immut/list.Nil,
    @immut/list.Cons(edge1, @immut/list.Nil),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeStart_with_edges
  let options : LayeredOptions = (
    80.0, // 更大的层间距
     50.0, // 更大的节点间距
     "DOWN", // 向下布局
     "DEGREE", // 按度数排序
     "ORTHOGONAL", // 正交边缘路由
     "CENTER", // 居中对齐
     true, // 考虑节点标签
     true, // 考虑端口位置
     1.5, // 更宽的宽高比
     25, // 更多迭代
  )
  layout_layered(root, options)
}
