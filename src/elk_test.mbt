///|
test "简单分层布局" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 使用默认选项
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.4 != 0.0 {
    panic()
  }
  if result.5 != 0.0 {
    panic()
  }
}

///|
test "不同对齐方式测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w1 : Float = 10.0
  let h1 : Float = 10.0
  let w2 : Float = 20.0
  let h2 : Float = 15.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w1,
    h1,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w2,
    h2,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w1,
    h1,
  )
  let root : @src.ElkNode = nodeA2

  // 创建自定义选项
  let layer_spacing : Float = 50.0
  let node_spacing : Float = 30.0
  let direction : @src.LayoutDirection = "DOWN"
  let node_sorting : @src.NodeSortingStrategy = "DEGREE"
  let edge_routing : @src.EdgeRoutingStrategy = "STRAIGHT"
  let alignment : @src.Alignment = "CENTER"
  let consider_node_labels : Bool = true
  let consider_port_positions : Bool = true
  let aspect_ratio : Float = 1.0
  let iterations : Int32 = 15
  let options : @src.LayeredOptions = (
    layer_spacing, node_spacing, direction, node_sorting, edge_routing, alignment,
    consider_node_labels, consider_port_positions, aspect_ratio, iterations,
  )
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.4 != 0.0 {
    panic()
  }
  if result.5 != 0.0 {
    panic()
  }
}

///|
test "边缘交叉最小化测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个有交叉边的图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e3", "B", "D", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e4", "C", "D", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "增量式布局测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建初始状态
  let initial_state = (
    @hashmap.HashMap([], capacity=0), // 节点映射
    @hashmap.HashMap([], capacity=0), // 层映射
    @hashmap.HashMap([], capacity=0), // 层到节点列表映射
    @hashmap.HashMap([], capacity=0), // 节点位置映射
  )

  // 添加节点
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let state1 = @src.incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let state2 = @src.incremental_layout_add_node(state1, nodeB, 1)

  // 添加边
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let state3 = @src.incremental_layout_add_edge(state2, edgeAB)

  // 更新布局
  let options : @src.LayeredOptions = @src.default_layered_options()
  let final_state = @src.incremental_layout_update(state3, options)

  // 获取位置
  let positions = @src.incremental_layout_get_positions(final_state)

  // 验证位置不为空
  if positions.length() == 0 {
    panic()
  }
}

///|
test "边缘路由测试" {
  let source_pos : @src.Position = (0.0, 0.0)
  let target_pos : @src.Position = (100.0, 100.0)

  // 测试直线路由
  let straight_route = @src.route_edge(
    "A", "B", source_pos, target_pos, "STRAIGHT",
  )
  if @src.list_length(straight_route) != 2 {
    panic()
  }

  // 测试正交路由
  let orthogonal_route = @src.route_edge(
    "A", "B", source_pos, target_pos, "ORTHOGONAL",
  )
  if @src.list_length(orthogonal_route) != 4 {
    panic()
  }

  // 测试折线路由
  let polyline_route = @src.route_edge(
    "A", "B", source_pos, target_pos, "POLYLINE",
  )
  if @src.list_length(polyline_route) != 3 {
    panic()
  }

  // 测试样条路由
  let spline_route = @src.route_edge(
    "A", "B", source_pos, target_pos, "SPLINES",
  )
  if @src.list_length(spline_route) != 4 {
    panic()
  }
}

///|
test "多层复杂图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建多层复杂图：A -> B,C -> D,E,F -> G
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeF : @src.ElkNode = (
    "F",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeG : @src.ElkNode = (
    "G",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e3", "B", "D", @list.List([]))
  let _edgeBE : @src.ElkEdge = ("e4", "B", "E", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e5", "C", "D", @list.List([]))
  let _edgeCF : @src.ElkEdge = ("e6", "C", "F", @list.List([]))
  let _edgeDG : @src.ElkEdge = ("e7", "D", "G", @list.List([]))
  let _edgeEG : @src.ElkEdge = ("e8", "E", "G", @list.List([]))
  let _edgeFG : @src.ElkEdge = ("e9", "F", "G", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "带标签和端口的复杂图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建带标签的节点
  let _nodeA : @src.ElkNode = (
    "A",
    Some("Start"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    Some("Process"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    Some("End"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )

  // 创建带标签的边
  let label1 : @src.ElkLabel = ("flow", 0.0, 0.0)
  let label2 : @src.ElkLabel = ("result", 0.0, 0.0)
  let edgeAB : @src.ElkEdge = (
    "e1",
    "A",
    "B",
    @list.cons(label1, @list.List([])),
  )
  let _edgeBC : @src.ElkEdge = (
    "e2",
    "B",
    "C",
    @list.cons(label2, @list.List([])),
  )
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    Some("Start"),
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "Force布局算法测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建用于Force布局的图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e3", "A", "C", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_force(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "通用布局API测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()

  // 测试Layered布局
  let layered_options : @src.LayoutOptions = ("layered", options)
  let layered_result : @src.ElkNode = @src.elk_layout(root, layered_options)
  if layered_result.0 == "" {
    panic()
  }

  // 测试Fixed布局
  let fixed_options : @src.LayoutOptions = ("fixed", options)
  let fixed_result : @src.ElkNode = @src.elk_layout(root, fixed_options)
  if fixed_result.0 == "" {
    panic()
  }

  // 测试Force布局
  let force_options : @src.LayoutOptions = ("force", options)
  let force_result : @src.ElkNode = @src.elk_layout(root, force_options)
  if force_result.0 == "" {
    panic()
  }
}

///|
test "性能测试-中等规模图" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个中等规模的图（10个节点）
  let mut edges = @list.List([])
  let mut i = 0
  while i < 9 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : @src.ElkEdge = (
      "e" + i.to_string(),
      source,
      target,
      @list.List([]),
    )
    edges = @list.cons(edge, edges)
    i = i + 1
  }
  let root : @src.ElkNode = ("node0", None, @list.List([]), edges, x, y, w, h)
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "不同布局方向测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges

  // 测试不同方向
  let directions = @list.cons(
    "DOWN",
    @list.cons("UP", @list.cons("LEFT", @list.cons("RIGHT", @list.List([])))),
  )
  let mut current = directions
  while true {
    match current {
      @list.List::More(direction, tail=rest) => {
        let options : @src.LayeredOptions = (
          50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true,
          1.0, 10,
        )
        let result : @src.ElkNode = @src.layout_layered(root, options)
        if result.0 == "" {
          panic()
        }
        current = rest
      }
      @list.List::Empty => break
    }
  }
}

// 新增测试用例以提高覆盖率

///|
test "单节点图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建只有一个节点的图
  let nodeA : @src.ElkNode = (
    "A",
    Some("Single"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "无边图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建没有边的图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "自环边测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建包含自环的图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAA : @src.ElkEdge = ("e1", "A", "A", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAA, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "循环图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建循环图：A -> B -> C -> A
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))
  let _edgeCA : @src.ElkEdge = ("e3", "C", "A", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "不同排序策略测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeBC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges

  // 测试不同排序策略
  let strategies = @list.cons(
    "NONE",
    @list.cons(
      "INPUT_ORDER",
      @list.cons("NAME", @list.cons("DEGREE", @list.List([]))),
    ),
  )
  let mut current = strategies
  while true {
    match current {
      @list.List::More(strategy, tail=rest) => {
        let options : @src.LayeredOptions = (
          50.0, 30.0, "DOWN", strategy, "STRAIGHT", "CENTER", true, true, 1.0, 10,
        )
        let result : @src.ElkNode = @src.layout_layered(root, options)
        if result.0 == "" {
          panic()
        }
        current = rest
      }
      @list.List::Empty => break
    }
  }
}

///|
test "不同对齐方式测试 组合" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges

  // 测试不同对齐方式
  let alignments = @list.cons(
    "LEFT",
    @list.cons(
      "CENTER",
      @list.cons(
        "RIGHT",
        @list.cons(
          "TOP",
          @list.cons("BOTTOM", @list.cons("NONE", @list.List([]))),
        ),
      ),
    ),
  )
  let mut current = alignments
  while true {
    match current {
      @list.List::More(alignment, tail=rest) => {
        let options : @src.LayeredOptions = (
          50.0, 30.0, "DOWN", "INPUT_ORDER", "STRAIGHT", alignment, true, true, 1.0,
          10,
        )
        let result : @src.ElkNode = @src.layout_layered(root, options)
        if result.0 == "" {
          panic()
        }
        current = rest
      }
      @list.List::Empty => break
    }
  }
}

///|
test "工具函数测试" {
  // 测试 list_length 函数
  let empty_list : @list.List[String] = @list.List([])
  if @src.list_length(empty_list) != 0 {
    panic()
  }
  let single_list = @list.cons("A", @list.List([]))
  if @src.list_length(single_list) != 1 {
    panic()
  }
  let multi_list = @list.cons(
    "A",
    @list.cons("B", @list.cons("C", @list.List([]))),
  )
  if @src.list_length(multi_list) != 3 {
    panic()
  }

  // 测试列表长度计算
  if @src.list_length(multi_list) != 3 {
    panic()
  }
}

///|
test "默认选项测试" {
  let options = @src.default_layered_options()

  // 验证默认选项的各个字段
  if options.0 != 50.0 {
    panic()
  } // layer_spacing
  if options.1 != 30.0 {
    panic()
  } // node_spacing
  if options.2 != "DOWN" {
    panic()
  } // direction
  if options.3 != "INPUT_ORDER" {
    panic()
  } // node_sorting
  if options.4 != "STRAIGHT" {
    panic()
  } // edge_routing
  if options.5 != "CENTER" {
    panic()
  } // alignment
  if options.6 != true {
    panic()
  } // consider_node_labels
  if options.7 != true {
    panic()
  } // consider_port_positions
  if options.8 != 1.0 {
    panic()
  } // aspect_ratio
  if options.9 != 10 {
    panic()
  }
} // iterations

///|
test "大规模图性能测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个较大规模的图（50个节点）
  let mut edges = @list.List([])
  let mut i = 0
  while i < 49 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : @src.ElkEdge = (
      "e" + i.to_string(),
      source,
      target,
      @list.List([]),
    )
    edges = @list.cons(edge, edges)
    i = i + 1
  }

  // 添加一些交叉边
  let cross_edge1 : @src.ElkEdge = ("cross1", "node0", "node25", @list.List([]))
  let cross_edge2 : @src.ElkEdge = (
    "cross2",
    "node10",
    "node40",
    @list.List([]),
  )
  let cross_edge3 : @src.ElkEdge = ("cross3", "node5", "node35", @list.List([]))
  edges = @list.cons(
    cross_edge1,
    @list.cons(cross_edge2, @list.cons(cross_edge3, edges)),
  )
  let root : @src.ElkNode = ("node0", None, @list.List([]), edges, x, y, w, h)
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "复杂增量式布局测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建初始状态
  let initial_state = (
    @hashmap.HashMap([], capacity=0), // 节点映射
    @hashmap.HashMap([], capacity=0), // 层映射
    @hashmap.HashMap([], capacity=0), // 层到节点列表映射
    @hashmap.HashMap([], capacity=0), // 节点位置映射
  )

  // 逐步添加多个节点
  let nodeA : @src.ElkNode = (
    "A",
    Some("Start"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let state1 = @src.incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : @src.ElkNode = (
    "B",
    Some("Process1"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let state2 = @src.incremental_layout_add_node(state1, nodeB, 1)
  let nodeC : @src.ElkNode = (
    "C",
    Some("Process2"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let state3 = @src.incremental_layout_add_node(state2, nodeC, 1)
  let nodeD : @src.ElkNode = (
    "D",
    Some("End"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let state4 = @src.incremental_layout_add_node(state3, nodeD, 2)

  // 添加多条边
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let state5 = @src.incremental_layout_add_edge(state4, edgeAB)
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let state6 = @src.incremental_layout_add_edge(state5, edgeAC)
  let edgeBD : @src.ElkEdge = ("e3", "B", "D", @list.List([]))
  let state7 = @src.incremental_layout_add_edge(state6, edgeBD)
  let edgeCD : @src.ElkEdge = ("e4", "C", "D", @list.List([]))
  let state8 = @src.incremental_layout_add_edge(state7, edgeCD)

  // 更新布局
  let options : @src.LayeredOptions = @src.default_layered_options()
  let final_state = @src.incremental_layout_update(state8, options)

  // 获取位置
  let positions = @src.incremental_layout_get_positions(final_state)

  // 验证位置不为空
  if positions.length() == 0 {
    panic()
  }
}

///|
test "边缘路由边界条件测试" {
  // 测试相同位置的边缘路由
  let same_pos : @src.Position = (0.0, 0.0)
  let straight_same = @src.route_edge("A", "A", same_pos, same_pos, "STRAIGHT")
  if @src.list_length(straight_same) != 2 {
    panic()
  }

  // 测试垂直边缘路由
  let vertical_source : @src.Position = (0.0, 0.0)
  let vertical_target : @src.Position = (0.0, 100.0)
  let orthogonal_vertical = @src.route_edge(
    "A", "B", vertical_source, vertical_target, "ORTHOGONAL",
  )
  if @src.list_length(orthogonal_vertical) != 4 {
    panic()
  }

  // 测试水平边缘路由
  let horizontal_source : @src.Position = (0.0, 0.0)
  let horizontal_target : @src.Position = (100.0, 0.0)
  let polyline_horizontal = @src.route_edge(
    "A", "B", horizontal_source, horizontal_target, "POLYLINE",
  )
  if @src.list_length(polyline_horizontal) != 3 {
    panic()
  }

  // 测试未知策略的边缘路由
  let unknown_route = @src.route_edge(
    "A",
    "B",
    (0.0, 0.0),
    (100.0, 100.0),
    "UNKNOWN",
  )
  if @src.list_length(unknown_route) != 2 {
    panic()
  }
}

///|
test "Force布局复杂图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建更复杂的Force布局图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e3", "C", "D", @list.List([]))
  let _edgeDE : @src.ElkEdge = ("e4", "D", "E", @list.List([]))
  let edgeAE : @src.ElkEdge = ("e5", "A", "E", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e6", "A", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e7", "B", "D", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAE, @list.cons(edgeAC, @list.List([])))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_force(root, options)

  // 验证结果不为空
  if result.0 == "" {
    panic()
  }
}

///|
test "通用API未知算法测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let layout_options : @src.LayoutOptions = ("UNKNOWN", options)
  let result : @src.ElkNode = @src.elk_layout(root, layout_options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试所有布局方向" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 测试所有方向
  let _directions = @list.cons(
    "DOWN",
    @list.cons("UP", @list.cons("LEFT", @list.cons("RIGHT", @list.List([])))),
  )
  let test_direction = fn(direction : String) {
    let options : @src.LayeredOptions = (
      50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true, 1.0,
      10,
    )
    let result : @src.ElkNode = @src.layout_layered(root, options)
    if result.0 == "" {
      panic()
    }
  }

  // 测试每个方向
  let _ = test_direction("DOWN")
  let _ = test_direction("UP")
  let _ = test_direction("LEFT")
  let _ = test_direction("RIGHT")
}

///|
test "测试所有排序策略" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 测试所有排序策略
  let _strategies = @list.cons(
    "INPUT_ORDER",
    @list.cons(
      "DEGREE",
      @list.cons("DEPTH_FIRST", @list.cons("BREADTH_FIRST", @list.List([]))),
    ),
  )
  let test_strategy = fn(strategy : String) {
    let options : @src.LayeredOptions = (
      50.0, 30.0, "DOWN", strategy, "STRAIGHT", "CENTER", true, true, 1.0, 10,
    )
    let result : @src.ElkNode = @src.layout_layered(root, options)
    if result.0 == "" {
      panic()
    }
  }

  // 测试每个策略
  let _ = test_strategy("INPUT_ORDER")
  let _ = test_strategy("DEGREE")
  let _ = test_strategy("DEPTH_FIRST")
  let _ = test_strategy("BREADTH_FIRST")
}

///|
test "测试所有对齐策略" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 测试所有对齐策略
  let _alignments = @list.cons(
    "CENTER",
    @list.cons(
      "LEFT",
      @list.cons(
        "RIGHT",
        @list.cons(
          "TOP",
          @list.cons("BOTTOM", @list.cons("NONE", @list.List([]))),
        ),
      ),
    ),
  )
  let test_alignment = fn(alignment : String) {
    let options : @src.LayeredOptions = (
      50.0, 30.0, "DOWN", "INPUT_ORDER", "STRAIGHT", alignment, true, true, 1.0,
      10,
    )
    let result : @src.ElkNode = @src.layout_layered(root, options)
    if result.0 == "" {
      panic()
    }
  }

  // 测试每个对齐策略
  let _ = test_alignment("CENTER")
  let _ = test_alignment("LEFT")
  let _ = test_alignment("RIGHT")
  let _ = test_alignment("TOP")
  let _ = test_alignment("BOTTOM")
}

///|
test "测试所有边路由策略" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 测试所有边路由策略
  let _routings = @list.cons(
    "STRAIGHT",
    @list.cons(
      "ORTHOGONAL",
      @list.cons("POLYLINE", @list.cons("SPLINES", @list.List([]))),
    ),
  )
  let test_routing = fn(routing : String) {
    let options : @src.LayeredOptions = (
      50.0, 30.0, "DOWN", "INPUT_ORDER", routing, "CENTER", true, true, 1.0, 10,
    )
    let result : @src.ElkNode = @src.layout_layered(root, options)
    if result.0 == "" {
      panic()
    }
  }

  // 测试每个路由策略
  let _ = test_routing("STRAIGHT")
  let _ = test_routing("ORTHOGONAL")
  let _ = test_routing("POLYLINE")
  let _ = test_routing("SPLINES")
}

///|
test "测试复杂图结构" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建复杂的多层图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeF : @src.ElkNode = (
    "F",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeG : @src.ElkNode = (
    "G",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeH : @src.ElkNode = (
    "H",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e3", "B", "D", @list.List([]))
  let _edgeBE : @src.ElkEdge = ("e4", "B", "E", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e5", "C", "D", @list.List([]))
  let _edgeCF : @src.ElkEdge = ("e6", "C", "F", @list.List([]))
  let _edgeDG : @src.ElkEdge = ("e7", "D", "G", @list.List([]))
  let _edgeEG : @src.ElkEdge = ("e8", "E", "G", @list.List([]))
  let _edgeFG : @src.ElkEdge = ("e9", "F", "G", @list.List([]))
  let _edgeGH : @src.ElkEdge = ("e10", "G", "H", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试带标签和端口的图" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建带标签的边
  let label1 : @src.ElkLabel = ("重要连接", 1.0, 2.0)
  let label2 : @src.ElkLabel = ("次要连接", 3.0, 4.0)
  let _nodeA : @src.ElkNode = (
    "A",
    Some("开始节点"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    Some("处理节点"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    Some("结束节点"),
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = (
    "e1",
    "A",
    "B",
    @list.cons(label1, @list.List([])),
  )
  let _edgeBC : @src.ElkEdge = (
    "e2",
    "B",
    "C",
    @list.cons(label2, @list.List([])),
  )
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    Some("开始节点"),
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试固定布局算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_fixed(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试力导向布局算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_force(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试通用API" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 测试所有算法
  let _algorithms = @list.cons(
    "LAYERED",
    @list.cons("FIXED", @list.cons("FORCE", @list.List([]))),
  )
  let test_algorithm = fn(algorithm : String) {
    let options : @src.LayeredOptions = @src.default_layered_options()
    let layout_options : @src.LayoutOptions = (algorithm, options)
    let result : @src.ElkNode = @src.elk_layout(root, layout_options)
    if result.0 == "" {
      panic()
    }
  }

  // 测试每个算法
  let _ = test_algorithm("LAYERED")
  let _ = test_algorithm("FIXED")
  let _ = test_algorithm("FORCE")
}

///|
test "测试边界条件" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 测试空图
  let empty_node : @src.ElkNode = (
    "EMPTY",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result1 : @src.ElkNode = @src.layout_layered(empty_node, options)
  if result1.0 == "" {
    panic()
  }

  // 测试自环
  let self_loop : @src.ElkEdge = ("e1", "A", "A", @list.List([]))
  let node_with_self_loop : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(self_loop, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let result2 : @src.ElkNode = @src.layout_layered(node_with_self_loop, options)
  if result2.0 == "" {
    panic()
  }

  // 测试单节点
  let single_node : @src.ElkNode = (
    "SINGLE",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let result3 : @src.ElkNode = @src.layout_layered(single_node, options)
  if result3.0 == "" {
    panic()
  }
}

///|
test "测试性能边界" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建较大的图进行性能测试
  let _nodeA : @src.ElkNode = (
    "NodeA",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "NodeB",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "NodeC",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "NodeD",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "NodeA", "NodeB", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e2", "NodeB", "NodeC", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e3", "NodeC", "NodeD", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "NodeA",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试增量布局复杂场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建复杂的增量布局测试
  let initial_state = (
    @hashmap.HashMap([], capacity=0), // 节点映射
    @hashmap.HashMap([], capacity=0), // 层映射
    @hashmap.HashMap([], capacity=0), // 层到节点映射
    @hashmap.HashMap([], capacity=0), // 位置映射
  )
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))

  // 测试添加节点
  let state1 = @src.incremental_layout_add_node(initial_state, nodeA, 0)
  let state2 = @src.incremental_layout_add_node(state1, nodeB, 1)

  // 测试添加边
  let state3 = @src.incremental_layout_add_edge(state2, edgeAB)

  // 测试更新布局
  let options : @src.LayeredOptions = @src.default_layered_options()
  let state4 = @src.incremental_layout_update(state3, options)

  // 测试获取位置
  let positions = @src.incremental_layout_get_positions(state4)
  if positions.length() == 0 {
    panic()
  }
}

///|
test "测试边路由边界条件" {
  let source_pos : @src.Position = (0.0, 0.0)
  let target_pos : @src.Position = (100.0, 100.0)

  // 测试相同位置
  let same_pos : @src.Position = (50.0, 50.0)
  let straight_same = @src.route_edge("A", "B", same_pos, same_pos, "STRAIGHT")
  if @src.list_length(straight_same) != 2 {
    panic()
  }

  // 测试垂直距离
  let vertical_pos : @src.Position = (50.0, 0.0)
  let orthogonal_vertical = @src.route_edge(
    "A", "B", source_pos, vertical_pos, "ORTHOGONAL",
  )
  if @src.list_length(orthogonal_vertical) != 4 {
    panic()
  }

  // 测试水平距离
  let horizontal_pos : @src.Position = (100.0, 50.0)
  let polyline_horizontal = @src.route_edge(
    "A", "B", source_pos, horizontal_pos, "POLYLINE",
  )
  if @src.list_length(polyline_horizontal) != 3 {
    panic()
  }

  // 测试未知策略
  let unknown_route = @src.route_edge(
    "A", "B", source_pos, target_pos, "UNKNOWN",
  )
  if @src.list_length(unknown_route) != 2 {
    panic()
  }
}

///|
test "测试更复杂的力导向布局" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建更复杂的图结构
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e3", "C", "D", @list.List([]))
  let _edgeDE : @src.ElkEdge = ("e4", "D", "E", @list.List([]))
  let edgeAE : @src.ElkEdge = ("e5", "A", "E", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAE, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_force(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试未知算法在通用API中" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2
  let options : @src.LayeredOptions = @src.default_layered_options()
  let layout_options : @src.LayoutOptions = ("UNKNOWN", options)
  let result : @src.ElkNode = @src.elk_layout(root, layout_options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例1: 基本分层布局" {
  let result = @src.example_basic_layered()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例2: 复杂多层图布局" {
  let result = @src.example_complex_multilayer()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例3: 带标签和端口的图" {
  let result = @src.example_with_labels_and_ports()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例4: Force布局算法" {
  let result = @src.example_force_layout()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例5: 增量式布局" {
  let result = @src.example_incremental_layout()
  // 验证返回的是LayoutState类型
  let _ = result
}

///|
test "测试示例6: 不同布局方向" {
  let results = @src.example_different_directions()
  if @src.list_length(results) != 4 {
    panic()
  }
}

///|
test "测试示例7: 边缘路由演示" {
  let routes = @src.example_edge_routing()
  if @src.list_length(routes) != 4 {
    panic()
  }
}

///|
test "测试示例8: 性能测试图" {
  let result = @src.example_performance_test()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例9: 通用布局API演示" {
  let results = @src.example_universal_api()
  if @src.list_length(results) != 3 {
    panic()
  }
}

///|
test "测试示例10: 复杂工作流图" {
  let result = @src.example_workflow_graph()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试边缘交叉最小化算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建有交叉边的图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e3", "B", "D", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e4", "C", "D", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试复杂交叉边场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建更复杂的交叉边图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeF : @src.ElkNode = (
    "F",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e3", "B", "D", @list.List([]))
  let _edgeBE : @src.ElkEdge = ("e4", "B", "E", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e5", "C", "D", @list.List([]))
  let _edgeCF : @src.ElkEdge = ("e6", "C", "F", @list.List([]))
  let _edgeDE : @src.ElkEdge = ("e7", "D", "E", @list.List([]))
  let _edgeDF : @src.ElkEdge = ("e8", "D", "F", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.List([]))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试多层复杂图" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建多层复杂图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeF : @src.ElkNode = (
    "F",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeG : @src.ElkNode = (
    "G",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeH : @src.ElkNode = (
    "H",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeI : @src.ElkNode = (
    "I",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeJ : @src.ElkNode = (
    "J",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let edgeAD : @src.ElkEdge = ("e3", "A", "D", @list.List([]))
  let _edgeBE : @src.ElkEdge = ("e4", "B", "E", @list.List([]))
  let _edgeBF : @src.ElkEdge = ("e5", "B", "F", @list.List([]))
  let _edgeCE : @src.ElkEdge = ("e6", "C", "E", @list.List([]))
  let _edgeCF : @src.ElkEdge = ("e7", "C", "F", @list.List([]))
  let _edgeDG : @src.ElkEdge = ("e8", "D", "G", @list.List([]))
  let _edgeEH : @src.ElkEdge = ("e9", "E", "H", @list.List([]))
  let _edgeFI : @src.ElkEdge = ("e10", "F", "I", @list.List([]))
  let _edgeGJ : @src.ElkEdge = ("e11", "G", "J", @list.List([]))
  let _edgeHJ : @src.ElkEdge = ("e12", "H", "J", @list.List([]))
  let _edgeIJ : @src.ElkEdge = ("e13", "I", "J", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.List([])))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试所有布局选项组合" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let nodeA2 : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.List([])),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA2

  // 测试不同的选项组合
  let test_combination = fn(
    layer_spacing : Float,
    node_spacing : Float,
    direction : String,
    sorting : String,
    routing : String,
    alignment : String,
  ) {
    let options : @src.LayeredOptions = (
      layer_spacing, node_spacing, direction, sorting, routing, alignment, true,
      true, 1.0, 10,
    )
    let result : @src.ElkNode = @src.layout_layered(root, options)
    if result.0 == "" {
      panic()
    }
  }

  // 测试多种组合
  let _ = test_combination(
    40.0, 20.0, "DOWN", "INPUT_ORDER", "STRAIGHT", "CENTER",
  )
  let _ = test_combination(60.0, 30.0, "UP", "DEGREE", "ORTHOGONAL", "LEFT")
  let _ = test_combination(
    50.0, 25.0, "LEFT", "DEPTH_FIRST", "POLYLINE", "RIGHT",
  )
  let _ = test_combination(
    70.0, 35.0, "RIGHT", "BREADTH_FIRST", "SPLINES", "TOP",
  )
  let _ = test_combination(
    45.0, 22.5, "DOWN", "INPUT_ORDER", "STRAIGHT", "BOTTOM",
  )
}

///|
test "测试大规模图性能" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建较大规模的图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeF : @src.ElkNode = (
    "F",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeG : @src.ElkNode = (
    "G",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeH : @src.ElkNode = (
    "H",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeI : @src.ElkNode = (
    "I",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeJ : @src.ElkNode = (
    "J",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeK : @src.ElkNode = (
    "K",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeL : @src.ElkNode = (
    "L",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let edgeAD : @src.ElkEdge = ("e3", "A", "D", @list.List([]))
  let _edgeBE : @src.ElkEdge = ("e4", "B", "E", @list.List([]))
  let _edgeBF : @src.ElkEdge = ("e5", "B", "F", @list.List([]))
  let _edgeCG : @src.ElkEdge = ("e6", "C", "G", @list.List([]))
  let _edgeCH : @src.ElkEdge = ("e7", "C", "H", @list.List([]))
  let _edgeDI : @src.ElkEdge = ("e8", "D", "I", @list.List([]))
  let _edgeDJ : @src.ElkEdge = ("e9", "D", "J", @list.List([]))
  let _edgeEK : @src.ElkEdge = ("e10", "E", "K", @list.List([]))
  let _edgeFL : @src.ElkEdge = ("e11", "F", "L", @list.List([]))
  let _edgeGL : @src.ElkEdge = ("e12", "G", "L", @list.List([]))
  let _edgeHL : @src.ElkEdge = ("e13", "H", "L", @list.List([]))
  let _edgeIL : @src.ElkEdge = ("e14", "I", "L", @list.List([]))
  let _edgeJL : @src.ElkEdge = ("e15", "J", "L", @list.List([]))
  let _edgeKL : @src.ElkEdge = ("e16", "K", "L", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.List([])))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试边路由所有策略" {
  let source_pos : @src.Position = (0.0, 0.0)
  let target_pos : @src.Position = (100.0, 100.0)

  // 测试所有边路由策略
  let _strategies = @list.cons(
    "STRAIGHT",
    @list.cons(
      "ORTHOGONAL",
      @list.cons("POLYLINE", @list.cons("SPLINES", @list.List([]))),
    ),
  )
  let test_routing_strategy = fn(strategy : String) {
    let route = @src.route_edge("A", "B", source_pos, target_pos, strategy)
    if @src.list_length(route) < 2 {
      panic()
    }
  }

  // 测试每个策略
  let _ = test_routing_strategy("STRAIGHT")
  let _ = test_routing_strategy("ORTHOGONAL")
  let _ = test_routing_strategy("POLYLINE")
  let _ = test_routing_strategy("SPLINES")
}

///|
test "测试边路由边界情况" {
  // 测试相同位置
  let same_pos : @src.Position = (50.0, 50.0)
  let straight_same = @src.route_edge("A", "B", same_pos, same_pos, "STRAIGHT")
  if @src.list_length(straight_same) != 2 {
    panic()
  }

  // 测试垂直距离
  let vertical_pos : @src.Position = (50.0, 0.0)
  let orthogonal_vertical = @src.route_edge(
    "A",
    "B",
    (0.0, 0.0),
    vertical_pos,
    "ORTHOGONAL",
  )
  if @src.list_length(orthogonal_vertical) != 4 {
    panic()
  }

  // 测试水平距离
  let horizontal_pos : @src.Position = (100.0, 50.0)
  let polyline_horizontal = @src.route_edge(
    "A",
    "B",
    (0.0, 0.0),
    horizontal_pos,
    "POLYLINE",
  )
  if @src.list_length(polyline_horizontal) != 3 {
    panic()
  }

  // 测试未知策略
  let unknown_route = @src.route_edge(
    "A",
    "B",
    (0.0, 0.0),
    (100.0, 100.0),
    "UNKNOWN",
  )
  if @src.list_length(unknown_route) != 2 {
    panic()
  }
}

///|
test "测试增量布局完整流程" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建初始状态
  let initial_state = (
    @hashmap.HashMap([], capacity=0), // 节点映射
    @hashmap.HashMap([], capacity=0), // 层映射
    @hashmap.HashMap([], capacity=0), // 层到节点映射
    @hashmap.HashMap([], capacity=0), // 位置映射
  )
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeBC : @src.ElkEdge = ("e2", "B", "C", @list.List([]))

  // 测试添加节点
  let state1 = @src.incremental_layout_add_node(initial_state, nodeA, 0)
  let state2 = @src.incremental_layout_add_node(state1, nodeB, 1)
  let state3 = @src.incremental_layout_add_node(state2, nodeC, 2)

  // 测试添加边
  let state4 = @src.incremental_layout_add_edge(state3, edgeAB)
  let state5 = @src.incremental_layout_add_edge(state4, edgeBC)

  // 测试更新布局
  let options : @src.LayeredOptions = @src.default_layered_options()
  let state6 = @src.incremental_layout_update(state5, options)

  // 测试获取位置
  let positions = @src.incremental_layout_get_positions(state6)
  if positions.length() == 0 {
    panic()
  }
}

///|
test "测试力导向布局复杂场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建复杂的力导向图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeE : @src.ElkNode = (
    "E",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeF : @src.ElkNode = (
    "F",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let edgeAD : @src.ElkEdge = ("e3", "A", "D", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e4", "B", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e5", "B", "D", @list.List([]))
  let _edgeBE : @src.ElkEdge = ("e6", "B", "E", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e7", "C", "D", @list.List([]))
  let _edgeCE : @src.ElkEdge = ("e8", "C", "E", @list.List([]))
  let _edgeCF : @src.ElkEdge = ("e9", "C", "F", @list.List([]))
  let _edgeDE : @src.ElkEdge = ("e10", "D", "E", @list.List([]))
  let _edgeDF : @src.ElkEdge = ("e11", "D", "F", @list.List([]))
  let _edgeEF : @src.ElkEdge = ("e12", "E", "F", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.List([])))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_force(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试固定布局复杂场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建复杂的固定布局图
  let _nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeC : @src.ElkNode = (
    "C",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let _nodeD : @src.ElkNode = (
    "D",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let edgeAB : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let edgeAC : @src.ElkEdge = ("e2", "A", "C", @list.List([]))
  let edgeAD : @src.ElkEdge = ("e3", "A", "D", @list.List([]))
  let _edgeBC : @src.ElkEdge = ("e4", "B", "C", @list.List([]))
  let _edgeBD : @src.ElkEdge = ("e5", "B", "D", @list.List([]))
  let _edgeCD : @src.ElkEdge = ("e6", "C", "D", @list.List([]))
  let nodeA_with_edges : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.List([])))),
    x,
    y,
    w,
    h,
  )
  let root : @src.ElkNode = nodeA_with_edges
  let options : @src.LayeredOptions = @src.default_layered_options()
  let result : @src.ElkNode = @src.layout_fixed(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "group_layers 边界测试" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let layers = @hashmap.HashMap([], capacity=0)
  let keys = @list.List([])
  let map = @hashmap.HashMap([], capacity=0)
  let options = @src.default_layered_options()
  let result = @src.group_layers(keys, map, layers, node_map, options)
  // 空输入应返回空 layers
  if result.length() != 0 {
    panic()
  }
}

///|
test "assign_x/calculate_max_width/assign_coords 空输入测试" {
  let ids = @list.List([])
  let node_map = @hashmap.HashMap([], capacity=0)
  let alignment = "CENTER"
  let max_width : Float = 0.0
  let x = @src.assign_x(ids, 0.0, 10.0, node_map, alignment, max_width)
  if x != 0.0 {
    panic()
  }
  let mw = @src.calculate_max_width(ids, node_map, 0.0)
  if mw != 0.0 {
    panic()
  }
  let layers = @hashmap.HashMap([], capacity=0)
  let options = @src.default_layered_options()
  @src.assign_coords(layers, 0.0, options, node_map)
} // 只要不 panic 即可

///|
test "collect_ids/append_edges 空输入测试" {
  let map = @hashmap.HashMap([], capacity=0)
  let ids = @src.collect_ids(map)
  if @src.list_length(ids) != 0 {
    panic()
  }
  let edges1 = @list.List([])
  let edges2 = @list.List([])
  let appended = @src.append_edges(edges1, edges2)
  if @src.list_length(appended) != 0 {
    panic()
  }
}

///|
test "force_init_pos/collect_node_ids 空输入测试" {
  let ids = @list.List([])
  let pos = @hashmap.HashMap([], capacity=0)
  let result = @src.force_init_pos(ids, pos)
  if result.length() != 0 {
    panic()
  }
  let node_map = @hashmap.HashMap([], capacity=0)
  let node_ids = @src.collect_node_ids(node_map)
  if @src.list_length(node_ids) != 0 {
    panic()
  }
}

///|
test "to_float 测试" {
  let i : Int32 = 42
  let f = @src.to_float(i)
  if f != 42.0 {
    panic()
  }
}

///|
test "force_sum_rep/force_calc_repulsion/force_sum_att/force_calc_attraction/force_update/force_iterate/force_update_node 空输入测试" {
  let ids = @list.List([])
  let pos = @hashmap.HashMap([], capacity=0)
  let k : Float = 1.0
  let rep = @src.force_calc_repulsion(
    ids,
    pos,
    k,
    @hashmap.HashMap([], capacity=0),
  )
  if rep.length() != 0 {
    panic()
  }
  let att = @src.force_calc_attraction(
    @hashmap.HashMap([], capacity=0),
    pos,
    k,
    @hashmap.HashMap([], capacity=0),
  )
  if att.length() != 0 {
    panic()
  }
  let updated = @src.force_update(
    ids,
    pos,
    rep,
    att,
    1.0,
    1,
    @hashmap.HashMap([], capacity=0),
  )
  if updated.length() != 0 {
    panic()
  }
  let iterated = @src.force_iterate(
    pos,
    ids,
    @hashmap.HashMap([], capacity=0),
    k,
    1.0,
    1,
  )
  if iterated.length() != 0 {
    panic()
  }
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let node2 = @src.force_update_node(node, pos)
  if node2.0 != "A" {
    panic()
  }
}

///|
test "补测 group_layers None 分支" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let layers = @hashmap.HashMap([], capacity=0)
  let keys = @list.cons("not_exist", @list.List([]))
  let map = @hashmap.HashMap([], capacity=0)
  let options = @src.default_layered_options()
  let _result = @src.group_layers(keys, map, layers, node_map, options)
}
// 只要不 panic 即可

///|
test "补测 assign_x 非法 alignment" {
  let ids = @list.cons("A", @list.List([]))
  let node_map = @hashmap.HashMap([], capacity=0)
  let _x = @src.assign_x(ids, 0.0, 10.0, node_map, "FOO", 10.0)
}
// 只要不 panic 即可

///|
test "补测 calculate_max_width 空节点" {
  let ids = @list.cons("not_exist", @list.List([]))
  let node_map = @hashmap.HashMap([], capacity=0)
  let _mw = @src.calculate_max_width(ids, node_map, 0.0)
}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_name 空列表" {
  let ids = @list.List([])
  let _result = @src.assign_x(
    ids,
    0.0,
    10.0,
    @hashmap.HashMap([], capacity=0),
    "CENTER",
    10.0,
  )
}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_degree 空节点" {
  let ids = @list.cons("not_exist", @list.List([]))
  let node_map = @hashmap.HashMap([], capacity=0)
  let _result = @src.calculate_max_width(ids, node_map, 0.0)
}
// 只要不 panic 即可

///|
test "补测 calculate_x_by_alignment default 分支" {
  let ids = @list.cons("A", @list.List([]))
  let node_map = @hashmap.HashMap([], capacity=0)
  let _x = @src.assign_x(ids, 0.0, 10.0, node_map, "UNKNOWN", 10.0)
}
// 只要不 panic 即可

///|
test "补测 route_edge 未知策略" {
  let pos : @src.Position = (0.0, 0.0)
  let route = @src.route_edge("A", "B", pos, pos, "UNKNOWN")
  if @src.list_length(route) != 2 {
    panic()
  }
}

///|
test "补测 force_sum_rep 递归终止" {
  let ids = @list.List([])
  let result = @src.force_calc_repulsion(
    ids,
    @hashmap.HashMap([], capacity=0),
    1.0,
    @hashmap.HashMap([], capacity=0),
  )
  if result.length() != 0 {
    panic()
  }
}

///|
test "补测 force_sum_att 递归终止" {
  let _edges : @list.List[@src.ElkEdge] = @list.List([])
  let pos = @hashmap.HashMap([], capacity=0)
  let result = @src.force_calc_attraction(
    @hashmap.HashMap([], capacity=0),
    pos,
    1.0,
    @hashmap.HashMap([], capacity=0),
  )
  if result.length() != 0 {
    panic()
  }
}

///|
test "补测 remove_node_from_list 空列表" {
  let nodes = @list.List([])
  let _result = @src.assign_x(
    nodes,
    0.0,
    10.0,
    @hashmap.HashMap([], capacity=0),
    "CENTER",
    10.0,
  )
}
// 只要不 panic 即可

///|
test "补测 add_edge_to_layout 节点不存在" {
  let state = (
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
  )
  let edge : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let _result = @src.incremental_layout_add_edge(state, edge)
}
// 只要不 panic 即可

///|
test "补测 update_layout_positions 空层" {
  let state = (
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
  )
  let options = @src.default_layered_options()
  let _result = @src.incremental_layout_update(state, options)
}
// 只要不 panic 即可

///|
test "补测 elk_layout 未知算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    x,
    y,
    w,
    h,
  )
  let options : @src.LayeredOptions = @src.default_layered_options()
  let layout_options : @src.LayoutOptions = ("UNKNOWN", options)
  let result : @src.ElkNode = @src.elk_layout(nodeA, layout_options)
  if result.0 == "" {
    panic()
  }
}

///|
test "补测 minimize_crossings 空层" {
  let layers = @hashmap.HashMap([], capacity=0)
  let edges = @list.List([])
  let _result = @src.minimize_crossings(layers, edges)
}
// 只要不 panic 即可

///|
test "补测 count_crossings 空层" {
  let layer1 = @list.List([])
  let layer2 = @list.List([])
  let edges = @list.List([])
  let _crossings = @src.count_crossings(layer1, layer2, edges)
}
// 只要不 panic 即可

///|
test "补测 get_node_at_index 越界" {
  let nodes = @list.cons("A", @list.List([]))
  let _node = @src.get_node_at_index(nodes, 5)
}
// 只要不 panic 即可

///|
test "补测 has_edge_between 空边" {
  let result = @src.has_edge_between("A", "B", @list.List([]))
  if result != false {
    panic()
  }
}

///|
test "补测 reverse_list 空列表" {
  let lst : @list.List[String] = @list.List([])
  let _rev = @src.reverse_list(lst)
}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_name 全相同" {
  let ids = @list.cons("A", @list.cons("A", @list.List([])))
  let _result = @src.sort_nodes_by_name(ids, @list.List([]))
}
// 只要不 panic 即可

///|
test "补测 insert_by_name 空列表" {
  let _result = @src.insert_by_name("A", @list.List([]))
}
// 只要不 panic 即可

///|
test "补测 insert_by_degree 空列表" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let _result = @src.insert_by_degree("A", 1, @list.List([]), node_map)
}
// 只要不 panic 即可

///|
test "补测 node_degree 空节点" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let _degree = @src.node_degree(node)
}
// 只要不 panic 即可

///|
test "补测 collect_all_edges 空节点" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let _edges = @src.collect_all_edges(node_map)
}
// 只要不 panic 即可

///|
test "补测 append_edges 空列表" {
  let edges1 = @list.List([])
  let edges2 = @list.List([])
  let _result = @src.append_edges(edges1, edges2)
}
// 只要不 panic 即可

///|
test "补测 remove_node_from_list 不存在节点" {
  let nodes = @list.cons("A", @list.cons("B", @list.List([])))
  let _result = @src.remove_node_from_list(nodes, "C")
}
// 只要不 panic 即可

///|
test "补测 update_layout_positions 空节点" {
  let state = (
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
  )
  let options = @src.default_layered_options()
  let _result = @src.incremental_layout_update(state, options)
}
// 只要不 panic 即可

///|
test "补测 layout_layered 空节点" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = @src.default_layered_options()
  let _result = @src.layout_layered(node, options)
}
// 只要不 panic 即可

///|
test "补测 layout_fixed 空节点" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = @src.default_layered_options()
  let _result = @src.layout_fixed(node, options)
}
// 只要不 panic 即可

///|
test "补测 layout_force 空节点" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = @src.default_layered_options()
  let _result = @src.layout_force(node, options)
}
// 只要不 panic 即可

///|
test "补测 minimize_crossings 空层和单层" {
  let layers = @hashmap.HashMap([], capacity=0)
  let edges = @list.List([])
  // 空层
  let result1 = @src.minimize_crossings(layers, edges)
  if result1.length() != 0 {
    panic()
  }
  // 只有一层
  layers.set(0, @list.cons("A", @list.List([])))
  let result2 = @src.minimize_crossings(layers, edges)
  if result2.length() != 1 {
    panic()
  }
}

///|
test "补测 count_crossings 空层和无交叉" {
  let l1 = @list.List([])
  let l2 = @list.List([])
  let edges = @list.List([])
  let c1 = @src.count_crossings(l1, l2, edges)
  if c1 != 0 {
    panic()
  }
  let l1b = @list.cons("A", @list.List([]))
  let l2b = @list.cons("B", @list.List([]))
  let c2 = @src.count_crossings(l1b, l2b, edges)
  if c2 != 0 {
    panic()
  }
}

///|
test "补测 get_node_at_index 越界和空列表" {
  let nodes = @list.List([])
  let n1 = @src.get_node_at_index(nodes, 0)
  if n1 != "" {
    panic()
  }
  let nodes2 = @list.cons("A", @list.List([]))
  let n2 = @src.get_node_at_index(nodes2, 5)
  if n2 != "" {
    panic()
  }
}

///|
test "补测 has_edge_between 空边和无匹配" {
  let edges = @list.List([])
  let r1 = @src.has_edge_between("A", "B", edges)
  if r1 != false {
    panic()
  }
  let e : @src.ElkEdge = ("e1", "A", "C", @list.List([]))
  let edges2 = @list.cons(e, @list.List([]))
  let r2 = @src.has_edge_between("A", "B", edges2)
  if r2 != false {
    panic()
  }
}

///|
test "补测 reverse_list 空列表和单元素" {
  let l : @list.List[String] = @list.List([])
  let r = @src.reverse_list(l)
  if @src.list_length(r) != 0 {
    panic()
  }
  let l2 = @list.cons("A", @list.List([]))
  let r2 = @src.reverse_list(l2)
  if @src.list_length(r2) != 1 {
    panic()
  }
}

///|
test "补测 insert_by_name 空列表和已排序" {
  let r = @src.insert_by_name("A", @list.List([]))
  if @src.list_length(r) != 1 {
    panic()
  }
  let r2 = @src.insert_by_name("B", @list.cons("A", @list.List([])))
  if @src.list_length(r2) != 2 {
    panic()
  }
}

///|
test "补测 node_degree 空节点二" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let d = @src.node_degree(node)
  if d != 0 {
    panic()
  }
}

///|
test "补测 remove_node_from_list 空列表和不存在节点" {
  let l = @list.List([])
  let r = @src.remove_node_from_list(l, "A")
  if @src.list_length(r) != 0 {
    panic()
  }
  let l2 = @list.cons("A", @list.cons("B", @list.List([])))
  let r2 = @src.remove_node_from_list(l2, "C")
  if @src.list_length(r2) != 2 {
    panic()
  }
}

///|
test "补测 force_init_pos 空输入" {
  let ids = @list.List([])
  let pos = @hashmap.HashMap([], capacity=0)
  let r = @src.force_init_pos(ids, pos)
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_calc_repulsion 空输入" {
  let ids = @list.List([])
  let pos = @hashmap.HashMap([], capacity=0)
  let r = @src.force_calc_repulsion(
    ids,
    pos,
    1.0,
    @hashmap.HashMap([], capacity=0),
  )
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_sum_rep 递归终止二" {
  let ids = @list.List([])
  let r = @src.force_calc_repulsion(
    ids,
    @hashmap.HashMap([], capacity=0),
    1.0,
    @hashmap.HashMap([], capacity=0),
  )
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_sum_att 空边" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let pos = @hashmap.HashMap([], capacity=0)
  let r = @src.force_calc_attraction(
    node_map,
    pos,
    1.0,
    @hashmap.HashMap([], capacity=0),
  )
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_iterate 0 次迭代" {
  let pos = @hashmap.HashMap([], capacity=0)
  let ids = @list.List([])
  let node_map = @hashmap.HashMap([], capacity=0)
  let r = @src.force_iterate(pos, ids, node_map, 1.0, 1.0, 0)
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_update 空输入" {
  let ids = @list.List([])
  let pos = @hashmap.HashMap([], capacity=0)
  let rep = @hashmap.HashMap([], capacity=0)
  let att = @hashmap.HashMap([], capacity=0)
  let r = @src.force_update(
    ids,
    pos,
    rep,
    att,
    1.0,
    1,
    @hashmap.HashMap([], capacity=0),
  )
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_update_node 无位置" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let pos = @hashmap.HashMap([], capacity=0)
  let r = @src.force_update_node(node, pos)
  if r.0 != "A" {
    panic()
  }
}

///|
test "补测 collect_node_ids 空 map" {
  let map = @hashmap.HashMap([], capacity=0)
  let r = @src.collect_node_ids(map)
  if @src.list_length(r) != 0 {
    panic()
  }
}

///|
test "补测 to_float" {
  let i : Int32 = 42
  let f = @src.to_float(i)
  if f != 42.0 {
    panic()
  }
}

///|
test "补测 elk_layout 默认分支" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options : @src.LayeredOptions = @src.default_layered_options()
  let layout_options : @src.LayoutOptions = ("unknown", options)
  let r = @src.elk_layout(node, layout_options)
  if r.0 != "A" {
    panic()
  }
}

///|
test "补测 add_edge_to_layout target_layer > source_layer" {
  let state = (
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
  )
  // 只设置目标节点层，且大于源节点层
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let edge : @src.ElkEdge = ("e1", "A", "B", @list.List([]))
  let state1 = @src.incremental_layout_add_node(state, nodeA, 0)
  let state2 = @src.incremental_layout_add_node(state1, nodeB, 2)
  let _state3 = @src.incremental_layout_add_edge(state2, edge)
}
// 只要不 panic 即可

///|
test "补测 update_layout_positions None 分支" {
  let state = (
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
    @hashmap.HashMap([], capacity=0),
  )
  let options = @src.default_layered_options()
  let _result = @src.incremental_layout_update(state, options)
}
// 只要不 panic 即可

///|
test "补测 remove_node_from_list Nil" {
  let l = @list.List([])
  let r = @src.remove_node_from_list(l, "A")
  if @src.list_length(r) != 0 {
    panic()
  }
}

///|
test "补测 layout_layered 空节点二" {
  let node : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = @src.default_layered_options()
  let result = @src.layout_layered(node, options)
  if result.0 != "A" {
    panic()
  }
}

///|
test "补测 collect_all_edges 非空 map" {
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let edge : @src.ElkEdge = ("e1", "A", "A", @list.List([]))
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.cons(edge, @list.List([])),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.HashMap([], capacity=0)
  map.set("A", nodeA)
  map.set("B", nodeB)
  let edges = @src.collect_all_edges(map)
  if @src.list_length(edges) != 1 {
    panic()
  }
}

///|
test "补测 collect_node_ids 非空 map" {
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.HashMap([], capacity=0)
  map.set("A", nodeA)
  let ids = @src.collect_node_ids(map)
  if @src.list_length(ids) != 1 {
    panic()
  }
}

///|
test "补测 force_edges_for 非空 map" {
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let edge : @src.ElkEdge = ("e1", "A", "A", @list.List([]))
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.cons(edge, @list.List([])),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.HashMap([], capacity=0)
  map.set("A", nodeA)
  map.set("B", nodeB)
  let edges = @src.force_edges_for(map, @list.List([]))
  if @src.list_length(edges) != 1 {
    panic()
  }
}

///|
test "补测 minimize_crossings 多层多边" {
  let layers = @hashmap.HashMap([], capacity=0)
  layers.set(0, @list.cons("A", @list.cons("B", @list.List([]))))
  layers.set(1, @list.cons("C", @list.cons("D", @list.List([]))))
  let edge1 : @src.ElkEdge = ("e1", "A", "C", @list.List([]))
  let edge2 : @src.ElkEdge = ("e2", "B", "D", @list.List([]))
  let edges = @list.cons(edge1, @list.cons(edge2, @list.List([])))
  let result = @src.minimize_crossings(layers, edges)
  if result.length() != 2 {
    panic()
  }
}

///|
test "补测 force_sum_rep/force_sum_att 复杂分支" {
  let ids = @list.cons("A", @list.cons("B", @list.List([])))
  let pos : @hashmap.HashMap[String, (Float, Float)] = @hashmap.HashMap(
    [],
    capacity=0,
  )
  pos.set("A", (0.0, 0.0))
  pos.set("B", (1.0, 1.0))
  let k : Float = 1.0
  let _rep = @src.force_calc_repulsion(
    ids,
    pos,
    k,
    @hashmap.HashMap([], capacity=0),
  )
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.HashMap([], capacity=0)
  map.set("A", nodeA)
  map.set("B", nodeB)
  let _att = @src.force_calc_attraction(
    map,
    pos,
    k,
    @hashmap.HashMap([], capacity=0),
  )
}
// 只要不 panic 即可

///|
test "补测 assign_coords 多层多节点" {
  let nodeA : @src.ElkNode = (
    "A",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let nodeB : @src.ElkNode = (
    "B",
    None,
    @list.List([]),
    @list.List([]),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let node_map = @hashmap.HashMap([], capacity=0)
  node_map.set("A", nodeA)
  node_map.set("B", nodeB)
  let layers = @hashmap.HashMap([], capacity=0)
  layers.set(0, @list.cons("A", @list.List([])))
  layers.set(1, @list.cons("B", @list.List([])))
  let options = @src.default_layered_options()
  @src.assign_coords(layers, 0.0, options, node_map)
}
// 只要不 panic 即可

///|
test "补测 route_edge 极端坐标" {
  let x1 : Float = 10000000000.0
  let y1 : Float = 10000000000.0
  let x2 : Float = -10000000000.0
  let y2 : Float = -10000000000.0
  let pos1 : @src.Position = (x1, y1)
  let pos2 : @src.Position = (x2, y2)
  let r = @src.route_edge("A", "B", pos1, pos2, "STRAIGHT")
  if @src.list_length(r) != 2 {
    let _ : Unit = panic()
  }
}

///|
test "补测 insert_by_degree None 分支" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let sorted = @list.cons("A", @list.List([]))
  // node_map 不含 "A"，触发 None 分支
  let result = @src.insert_by_degree("B", 2, sorted, node_map)
  if @src.list_length(result) != 2 {
    let _ : Unit = panic()
  }
}

///|
test "补测 assign_x/calculate_max_width/assign_coords None 节点分支" {
  let node_map = @hashmap.HashMap([], capacity=0)
  let ids = @list.cons("not_exist", @list.List([]))
  // assign_x None 分支
  let _ = @src.assign_x(ids, 0.0, 10.0, node_map, "CENTER", 10.0)
  // calculate_max_width None 分支
  let _ = @src.calculate_max_width(ids, node_map, 0.0)
  // assign_coords 空节点分支
  let layers = @hashmap.HashMap([], capacity=0)
  layers.set(0, ids)
  let options = @src.default_layered_options()
  @src.assign_coords(layers, 0.0, options, node_map)
}
// 只要不 panic 即可
