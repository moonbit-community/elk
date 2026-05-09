// examples.mbt: ELK 布局库使用示例

// 示例1: 基本分层布局

///|
pub fn example_basic_layered() -> ElkNode {
  // 创建简单的图结构：A -> B -> C
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
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
  let _nodeA : ElkNode = (
    "A",
    Some("Start"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeB : ElkNode = (
    "B",
    Some("Process1"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeC : ElkNode = (
    "C",
    Some("Process2"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeD : ElkNode = (
    "D",
    Some("Sub1"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeE : ElkNode = (
    "E",
    Some("Sub2"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeF : ElkNode = (
    "F",
    Some("Sub3"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeG : ElkNode = (
    "G",
    Some("End"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e3", "B", "D", @list.empty())
  let _edgeBE : ElkEdge = ("e4", "B", "E", @list.empty())
  let _edgeCD : ElkEdge = ("e5", "C", "D", @list.empty())
  let _edgeCF : ElkEdge = ("e6", "C", "F", @list.empty())
  let _edgeDG : ElkEdge = ("e7", "D", "G", @list.empty())
  let _edgeEG : ElkEdge = ("e8", "E", "G", @list.empty())
  let _edgeFG : ElkEdge = ("e9", "F", "G", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Start"),
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
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
  let _nodeA : ElkNode = (
    "A",
    Some("Input"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeB : ElkNode = (
    "B",
    Some("Process"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeC : ElkNode = (
    "C",
    Some("Output"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )

  // 创建带标签的边
  let label1 : ElkLabel = ("data", 0.0, 0.0)
  let label2 : ElkLabel = ("result", 0.0, 0.0)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.cons(label1, @list.empty()))
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.cons(label2, @list.empty()))
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Input"),
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let _edgeCD : ElkEdge = ("e3", "C", "D", @list.empty())
  let edgeAD : ElkEdge = ("e4", "A", "D", @list.empty())
  let edgeAC : ElkEdge = ("e5", "A", "C", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAD, @list.cons(edgeAC, @list.empty()))),
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
    @hashmap.HashMap([], capacity=0), // 节点映射
    @hashmap.HashMap([], capacity=0), // 层映射
    @hashmap.HashMap([], capacity=0), // 层到节点列表映射
    @hashmap.HashMap([], capacity=0), // 节点位置映射
  )
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 逐步添加节点
  let nodeA : ElkNode = (
    "A",
    Some("Start"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : ElkNode = (
    "B",
    Some("Process"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let state2 = incremental_layout_add_node(state1, nodeB, 1)
  let nodeC : ElkNode = (
    "C",
    Some("End"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let state3 = incremental_layout_add_node(state2, nodeC, 2)

  // 添加边
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let state4 = incremental_layout_add_edge(state3, edgeAB)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let state5 = incremental_layout_add_edge(state4, edgeBC)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  incremental_layout_update(state5, options)
}

// 示例6: 不同布局方向

///|
pub fn example_different_directions() -> @list.List[ElkNode] {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges

  // 测试不同方向
  let directions = @list.cons(
    "DOWN",
    @list.cons("UP", @list.cons("LEFT", @list.cons("RIGHT", @list.empty()))),
  )
  let mut results = @list.empty()
  let mut current = directions
  while true {
    match current {
      @list.List::More(direction, tail=rest) => {
        let options : LayeredOptions = (
          50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true,
          1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
        results = @list.cons(result, results)
        current = rest
      }
      @list.List::Empty => break
    }
  }
  results
}

// 示例7: 边缘路由演示

///|
pub fn example_edge_routing() -> @list.List[@list.List[Position]] {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试所有边缘路由策略
  let strategies = @list.cons(
    "STRAIGHT",
    @list.cons(
      "ORTHOGONAL",
      @list.cons("POLYLINE", @list.cons("SPLINES", @list.empty())),
    ),
  )
  let mut routes = @list.empty()
  let mut current = strategies
  while true {
    match current {
      @list.List::More(strategy, tail=rest) => {
        let route = route_edge("A", "B", source_pos, target_pos, strategy)
        routes = @list.cons(route, routes)
        current = rest
      }
      @list.List::Empty => break
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
  let mut edges = @list.empty()
  let mut i = 0
  while i < 19 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @list.empty())
    edges = @list.cons(edge, edges)
    i = i + 1
  }

  // 添加一些交叉边
  let cross_edge1 : ElkEdge = ("cross1", "node0", "node10", @list.empty())
  let cross_edge2 : ElkEdge = ("cross2", "node5", "node15", @list.empty())
  edges = @list.cons(cross_edge1, @list.cons(cross_edge2, edges))
  let root : ElkNode = ("node0", None, @list.empty(), edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  layout_layered(root, options)
}

// 示例9: 通用布局API演示

///|
pub fn example_universal_api() -> @list.List[ElkNode] {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
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
  @list.cons(
    layered_result,
    @list.cons(force_result, @list.cons(fixed_result, @list.empty())),
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
  let _nodeStart : ElkNode = (
    "Start",
    Some("开始"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeDecision : ElkNode = (
    "Decision",
    Some("决策"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeBranch1 : ElkNode = (
    "Branch1",
    Some("分支1"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeBranch2 : ElkNode = (
    "Branch2",
    Some("分支2"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeMerge : ElkNode = (
    "Merge",
    Some("合并"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeEnd : ElkNode = (
    "End",
    Some("结束"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let edge1 : ElkEdge = ("e1", "Start", "Decision", @list.empty())
  let _edge2 : ElkEdge = ("e2", "Decision", "Branch1", @list.empty())
  let _edge3 : ElkEdge = ("e3", "Decision", "Branch2", @list.empty())
  let _edge4 : ElkEdge = ("e4", "Branch1", "Merge", @list.empty())
  let _edge5 : ElkEdge = ("e5", "Branch2", "Merge", @list.empty())
  let _edge6 : ElkEdge = ("e6", "Merge", "End", @list.empty())
  let nodeStart_with_edges : ElkNode = (
    "Start",
    Some("开始"),
    @list.empty(),
    @list.cons(edge1, @list.empty()),
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
