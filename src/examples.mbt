// examples.mbt: ELK 布局库使用示例

// 示例1: 基本分层布局

///|
pub fn example_basic_layered() -> ElkNode {
  // 创建简单的图结构：A -> B -> C
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
  let nodeA : ElkNode = ("A", Some("Start"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = (
    "B",
    Some("Process1"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeC : ElkNode = (
    "C",
    Some("Process2"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeD : ElkNode = ("D", Some("Sub1"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", Some("Sub2"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", Some("Sub3"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeG : ElkNode = ("G", Some("End"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.T.Nil)
  let edgeBE : ElkEdge = ("e4", "B", "E", @list.T.Nil)
  let edgeCD : ElkEdge = ("e5", "C", "D", @list.T.Nil)
  let edgeCF : ElkEdge = ("e6", "C", "F", @list.T.Nil)
  let edgeDG : ElkEdge = ("e7", "D", "G", @list.T.Nil)
  let edgeEG : ElkEdge = ("e8", "E", "G", @list.T.Nil)
  let edgeFG : ElkEdge = ("e9", "F", "G", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Start"),
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
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
  let nodeA : ElkNode = ("A", Some("Input"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", Some("Process"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", Some("Output"), @list.T.Nil, @list.T.Nil, x, y, w, h)

  // 创建带标签的边
  let label1 : ElkLabel = ("data", 0.0, 0.0)
  let label2 : ElkLabel = ("result", 0.0, 0.0)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.[label1, ..@list.T.Nil])
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.[label2, ..@list.T.Nil])
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Input"),
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let edgeCD : ElkEdge = ("e3", "C", "D", @list.T.Nil)
  let edgeAD : ElkEdge = ("e4", "A", "D", @list.T.Nil)
  let edgeAC : ElkEdge = ("e5", "A", "C", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAD, @list.T.Cons(edgeAC, @list.T.Nil])),
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
    @hashmap.T.new(), // 节点映射
    @hashmap.T.new(), // 层映射
    @hashmap.T.new(), // 层到节点列表映射
    @hashmap.T.new(), // 节点位置映射
  )
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 逐步添加节点
  let nodeA : ElkNode = ("A", Some("Start"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : ElkNode = ("B", Some("Process"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state2 = incremental_layout_add_node(state1, nodeB, 1)
  let nodeC : ElkNode = ("C", Some("End"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state3 = incremental_layout_add_node(state2, nodeC, 2)

  // 添加边
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let state4 = incremental_layout_add_edge(state3, edgeAB)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let state5 = incremental_layout_add_edge(state4, edgeBC)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  incremental_layout_update(state5, options)
}

// 示例6: 不同布局方向

///|
pub fn example_different_directions() -> @list.T[ElkNode] {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges

  // 测试不同方向
  let directions = @list.T.[
    "DOWN", ..@list.T.Cons("UP", @list.T.Cons("LEFT", @list.T.Cons("RIGHT", @list.T.Nil])),
  )
  let mut results = @list.T.Nil
  let mut current = directions
  while true {
    match current {
      @list.T.[direction, ..rest] => {
        let options : LayeredOptions = (
          50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true,
          1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
        results = @list.T.[result, ..results]
        current = rest
      }
      @list.T.[] => break
    }
  }
  results
}

// 示例7: 边缘路由演示

///|
pub fn example_edge_routing() -> @list.T[@list.T[Position]] {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试所有边缘路由策略
  let strategies = @list.T.[
    "STRAIGHT", ..@list.T.Cons(
      "ORTHOGONAL",
      @list.T.Cons("POLYLINE", @list.T.Cons("SPLINES", @list.T.Nil]),
    ),
  )
  let mut routes = @list.T.Nil
  let mut current = strategies
  while true {
    match current {
      @list.T.[strategy, ..rest] => {
        let route = route_edge("A", "B", source_pos, target_pos, strategy)
        routes = @list.T.[route, ..routes]
        current = rest
      }
      @list.T.[] => break
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
  let mut edges = @list.T.Nil
  let mut i = 0
  while i < 19 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @list.T.Nil)
    edges = @list.T.[edge, ..edges]
    i = i + 1
  }

  // 添加一些交叉边
  let cross_edge1 : ElkEdge = ("cross1", "node0", "node10", @list.T.Nil)
  let cross_edge2 : ElkEdge = ("cross2", "node5", "node15", @list.T.Nil)
  edges = @list.T.[cross_edge1, ..@list.T.Cons(cross_edge2, edges])
  let root : ElkNode = ("node0", None, @list.T.Nil, edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  layout_layered(root, options)
}

// 示例9: 通用布局API演示

///|
pub fn example_universal_api() -> @list.T[ElkNode] {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
  @list.T.[
    layered_result, ..@list.T.Cons(force_result, @list.T.Cons(fixed_result, @list.T.Nil]),
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
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeDecision : ElkNode = (
    "Decision",
    Some("决策"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeBranch1 : ElkNode = (
    "Branch1",
    Some("分支1"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeBranch2 : ElkNode = (
    "Branch2",
    Some("分支2"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeMerge : ElkNode = (
    "Merge",
    Some("合并"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeEnd : ElkNode = (
    "End",
    Some("结束"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let edge1 : ElkEdge = ("e1", "Start", "Decision", @list.T.Nil)
  let edge2 : ElkEdge = ("e2", "Decision", "Branch1", @list.T.Nil)
  let edge3 : ElkEdge = ("e3", "Decision", "Branch2", @list.T.Nil)
  let edge4 : ElkEdge = ("e4", "Branch1", "Merge", @list.T.Nil)
  let edge5 : ElkEdge = ("e5", "Branch2", "Merge", @list.T.Nil)
  let edge6 : ElkEdge = ("e6", "Merge", "End", @list.T.Nil)
  let nodeStart_with_edges : ElkNode = (
    "Start",
    Some("开始"),
    @list.T.Nil,
    @list.T.[edge1, ..@list.T.Nil],
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
