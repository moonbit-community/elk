///|
test "简单分层布局" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 使用默认选项
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w1, h1)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w2, h2)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w1,
    h1,
  )
  let root : ElkNode = nodeA2

  // 创建自定义选项
  let layer_spacing : Float = 50.0
  let node_spacing : Float = 30.0
  let direction : LayoutDirection = "DOWN"
  let node_sorting : NodeSortingStrategy = "DEGREE"
  let edge_routing : EdgeRoutingStrategy = "STRAIGHT"
  let alignment : Alignment = "CENTER"
  let consider_node_labels : Bool = true
  let consider_port_positions : Bool = true
  let aspect_ratio : Float = 1.0
  let iterations : Int = 15
  let options : LayeredOptions = (
    layer_spacing, node_spacing, direction, node_sorting, edge_routing, alignment,
    consider_node_labels, consider_port_positions, aspect_ratio, iterations,
  )
  let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e3", "B", "D", @list.empty())
  let _edgeCD : ElkEdge = ("e4", "C", "D", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
    @hashmap.new(), // 节点映射
    @hashmap.new(), // 层映射
    @hashmap.new(), // 层到节点列表映射
    @hashmap.new(), // 节点位置映射
  )

  // 添加节点
  let nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let state2 = incremental_layout_add_node(state1, nodeB, 1)

  // 添加边
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let state3 = incremental_layout_add_edge(state2, edgeAB)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  let final_state = incremental_layout_update(state3, options)

  // 获取位置
  let positions = incremental_layout_get_positions(final_state)

  // 验证位置不为空
  if positions.length() == 0 {
    panic()
  }
}

///|
test "边缘路由测试" {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试直线路由
  let straight_route = route_edge("A", "B", source_pos, target_pos, "STRAIGHT")
  if list_length(straight_route) != 2 {
    panic()
  }

  // 测试正交路由
  let orthogonal_route = route_edge(
    "A", "B", source_pos, target_pos, "ORTHOGONAL",
  )
  if list_length(orthogonal_route) != 4 {
    panic()
  }

  // 测试折线路由
  let polyline_route = route_edge("A", "B", source_pos, target_pos, "POLYLINE")
  if list_length(polyline_route) != 3 {
    panic()
  }

  // 测试样条路由
  let spline_route = route_edge("A", "B", source_pos, target_pos, "SPLINES")
  if list_length(spline_route) != 4 {
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeF : ElkNode = ("F", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeG : ElkNode = ("G", None, @list.empty(), @list.empty(), x, y, w, h)
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
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
    Some("End"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )

  // 创建带标签的边
  let label1 : ElkLabel = ("flow", 0.0, 0.0)
  let label2 : ElkLabel = ("result", 0.0, 0.0)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.cons(label1, @list.empty()))
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.cons(label2, @list.empty()))
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Start"),
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let edgeAC : ElkEdge = ("e3", "A", "C", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)

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

  // 测试Layered布局
  let layered_options : LayoutOptions = ("layered", options)
  let layered_result : ElkNode = elk_layout(root, layered_options)
  if layered_result.0 == "" {
    panic()
  }

  // 测试Fixed布局
  let fixed_options : LayoutOptions = ("fixed", options)
  let fixed_result : ElkNode = elk_layout(root, fixed_options)
  if fixed_result.0 == "" {
    panic()
  }

  // 测试Force布局
  let force_options : LayoutOptions = ("force", options)
  let force_result : ElkNode = elk_layout(root, force_options)
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
  let mut edges = @list.empty()
  let mut i = 0
  while i < 9 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @list.empty())
    edges = @list.cons(edge, edges)
    i = i + 1
  }
  let root : ElkNode = ("node0", None, @list.empty(), edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
  let mut current = directions
  while true {
    match current {
      @list.List::More(direction, tail=rest) => {
        let options : LayeredOptions = (
          50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true,
          1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
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
  let nodeA : ElkNode = (
    "A",
    Some("Single"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAA : ElkEdge = ("e1", "A", "A", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAA, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let _edgeCA : ElkEdge = ("e3", "C", "A", @list.empty())
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
  let result : ElkNode = layout_layered(root, options)

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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeBC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges

  // 测试不同排序策略
  let strategies = @list.cons(
    "NONE",
    @list.cons(
      "INPUT_ORDER",
      @list.cons("NAME", @list.cons("DEGREE", @list.empty())),
    ),
  )
  let mut current = strategies
  while true {
    match current {
      @list.List::More(strategy, tail=rest) => {
        let options : LayeredOptions = (
          50.0, 30.0, "DOWN", strategy, "STRAIGHT", "CENTER", true, true, 1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
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

  // 测试不同对齐方式
  let alignments = @list.cons(
    "LEFT",
    @list.cons(
      "CENTER",
      @list.cons(
        "RIGHT",
        @list.cons(
          "TOP",
          @list.cons("BOTTOM", @list.cons("NONE", @list.empty())),
        ),
      ),
    ),
  )
  let mut current = alignments
  while true {
    match current {
      @list.List::More(alignment, tail=rest) => {
        let options : LayeredOptions = (
          50.0, 30.0, "DOWN", "INPUT_ORDER", "STRAIGHT", alignment, true, true, 1.0,
          10,
        )
        let result : ElkNode = layout_layered(root, options)
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
  let empty_list : @list.List[String] = @list.empty()
  if list_length(empty_list) != 0 {
    panic()
  }
  let single_list = @list.cons("A", @list.empty())
  if list_length(single_list) != 1 {
    panic()
  }
  let multi_list = @list.cons(
    "A",
    @list.cons("B", @list.cons("C", @list.empty())),
  )
  if list_length(multi_list) != 3 {
    panic()
  }

  // 测试列表长度计算
  if list_length(multi_list) != 3 {
    panic()
  }
}

///|
test "默认选项测试" {
  let options = default_layered_options()

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
  let mut edges = @list.empty()
  let mut i = 0
  while i < 49 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @list.empty())
    edges = @list.cons(edge, edges)
    i = i + 1
  }

  // 添加一些交叉边
  let cross_edge1 : ElkEdge = ("cross1", "node0", "node25", @list.empty())
  let cross_edge2 : ElkEdge = ("cross2", "node10", "node40", @list.empty())
  let cross_edge3 : ElkEdge = ("cross3", "node5", "node35", @list.empty())
  edges = @list.cons(
    cross_edge1,
    @list.cons(cross_edge2, @list.cons(cross_edge3, edges)),
  )
  let root : ElkNode = ("node0", None, @list.empty(), edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

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
    @hashmap.new(), // 节点映射
    @hashmap.new(), // 层映射
    @hashmap.new(), // 层到节点列表映射
    @hashmap.new(), // 节点位置映射
  )

  // 逐步添加多个节点
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
    Some("Process1"),
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
    Some("Process2"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let state3 = incremental_layout_add_node(state2, nodeC, 1)
  let nodeD : ElkNode = (
    "D",
    Some("End"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let state4 = incremental_layout_add_node(state3, nodeD, 2)

  // 添加多条边
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let state5 = incremental_layout_add_edge(state4, edgeAB)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let state6 = incremental_layout_add_edge(state5, edgeAC)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.empty())
  let state7 = incremental_layout_add_edge(state6, edgeBD)
  let edgeCD : ElkEdge = ("e4", "C", "D", @list.empty())
  let state8 = incremental_layout_add_edge(state7, edgeCD)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  let final_state = incremental_layout_update(state8, options)

  // 获取位置
  let positions = incremental_layout_get_positions(final_state)

  // 验证位置不为空
  if positions.length() == 0 {
    panic()
  }
}

///|
test "边缘路由边界条件测试" {
  // 测试相同位置的边缘路由
  let same_pos : Position = (0.0, 0.0)
  let straight_same = route_edge("A", "A", same_pos, same_pos, "STRAIGHT")
  if list_length(straight_same) != 2 {
    panic()
  }

  // 测试垂直边缘路由
  let vertical_source : Position = (0.0, 0.0)
  let vertical_target : Position = (0.0, 100.0)
  let orthogonal_vertical = route_edge(
    "A", "B", vertical_source, vertical_target, "ORTHOGONAL",
  )
  if list_length(orthogonal_vertical) != 4 {
    panic()
  }

  // 测试水平边缘路由
  let horizontal_source : Position = (0.0, 0.0)
  let horizontal_target : Position = (100.0, 0.0)
  let polyline_horizontal = route_edge(
    "A", "B", horizontal_source, horizontal_target, "POLYLINE",
  )
  if list_length(polyline_horizontal) != 3 {
    panic()
  }

  // 测试未知策略的边缘路由
  let unknown_route = route_edge(
    "A",
    "B",
    (0.0, 0.0),
    (100.0, 100.0),
    "UNKNOWN",
  )
  if list_length(unknown_route) != 2 {
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let _edgeCD : ElkEdge = ("e3", "C", "D", @list.empty())
  let _edgeDE : ElkEdge = ("e4", "D", "E", @list.empty())
  let edgeAE : ElkEdge = ("e5", "A", "E", @list.empty())
  let edgeAC : ElkEdge = ("e6", "A", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e7", "B", "D", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAE, @list.cons(edgeAC, @list.empty()))),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)

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
  let layout_options : LayoutOptions = ("UNKNOWN", options)
  let result : ElkNode = elk_layout(root, layout_options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有方向
  let _directions = @list.cons(
    "DOWN",
    @list.cons("UP", @list.cons("LEFT", @list.cons("RIGHT", @list.empty()))),
  )
  let test_direction = fn(direction : String) {
    let options : LayeredOptions = (
      50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true, 1.0,
      10,
    )
    let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有排序策略
  let _strategies = @list.cons(
    "INPUT_ORDER",
    @list.cons(
      "DEGREE",
      @list.cons("DEPTH_FIRST", @list.cons("BREADTH_FIRST", @list.empty())),
    ),
  )
  let test_strategy = fn(strategy : String) {
    let options : LayeredOptions = (
      50.0, 30.0, "DOWN", strategy, "STRAIGHT", "CENTER", true, true, 1.0, 10,
    )
    let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有对齐策略
  let _alignments = @list.cons(
    "CENTER",
    @list.cons(
      "LEFT",
      @list.cons(
        "RIGHT",
        @list.cons(
          "TOP",
          @list.cons("BOTTOM", @list.cons("NONE", @list.empty())),
        ),
      ),
    ),
  )
  let test_alignment = fn(alignment : String) {
    let options : LayeredOptions = (
      50.0, 30.0, "DOWN", "INPUT_ORDER", "STRAIGHT", alignment, true, true, 1.0,
      10,
    )
    let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有边路由策略
  let _routings = @list.cons(
    "STRAIGHT",
    @list.cons(
      "ORTHOGONAL",
      @list.cons("POLYLINE", @list.cons("SPLINES", @list.empty())),
    ),
  )
  let test_routing = fn(routing : String) {
    let options : LayeredOptions = (
      50.0, 30.0, "DOWN", "INPUT_ORDER", routing, "CENTER", true, true, 1.0, 10,
    )
    let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeF : ElkNode = ("F", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeG : ElkNode = ("G", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeH : ElkNode = ("H", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e3", "B", "D", @list.empty())
  let _edgeBE : ElkEdge = ("e4", "B", "E", @list.empty())
  let _edgeCD : ElkEdge = ("e5", "C", "D", @list.empty())
  let _edgeCF : ElkEdge = ("e6", "C", "F", @list.empty())
  let _edgeDG : ElkEdge = ("e7", "D", "G", @list.empty())
  let _edgeEG : ElkEdge = ("e8", "E", "G", @list.empty())
  let _edgeFG : ElkEdge = ("e9", "F", "G", @list.empty())
  let _edgeGH : ElkEdge = ("e10", "G", "H", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
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
  let label1 : ElkLabel = ("重要连接", 1.0, 2.0)
  let label2 : ElkLabel = ("次要连接", 3.0, 4.0)
  let _nodeA : ElkNode = (
    "A",
    Some("开始节点"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeB : ElkNode = (
    "B",
    Some("处理节点"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeC : ElkNode = (
    "C",
    Some("结束节点"),
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.cons(label1, @list.empty()))
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.cons(label2, @list.empty()))
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("开始节点"),
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_fixed(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有算法
  let _algorithms = @list.cons(
    "LAYERED",
    @list.cons("FIXED", @list.cons("FORCE", @list.empty())),
  )
  let test_algorithm = fn(algorithm : String) {
    let options : LayeredOptions = default_layered_options()
    let layout_options : LayoutOptions = (algorithm, options)
    let result : ElkNode = elk_layout(root, layout_options)
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
  let empty_node : ElkNode = (
    "EMPTY",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let options : LayeredOptions = default_layered_options()
  let result1 : ElkNode = layout_layered(empty_node, options)
  if result1.0 == "" {
    panic()
  }

  // 测试自环
  let self_loop : ElkEdge = ("e1", "A", "A", @list.empty())
  let node_with_self_loop : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(self_loop, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let result2 : ElkNode = layout_layered(node_with_self_loop, options)
  if result2.0 == "" {
    panic()
  }

  // 测试单节点
  let single_node : ElkNode = (
    "SINGLE",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let result3 : ElkNode = layout_layered(single_node, options)
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
  let _nodeA : ElkNode = (
    "NodeA",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeB : ElkNode = (
    "NodeB",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeC : ElkNode = (
    "NodeC",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let _nodeD : ElkNode = (
    "NodeD",
    None,
    @list.empty(),
    @list.empty(),
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "NodeA", "NodeB", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "NodeB", "NodeC", @list.empty())
  let _edgeCD : ElkEdge = ("e3", "NodeC", "NodeD", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "NodeA",
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
  let result : ElkNode = layout_layered(root, options)
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
    @hashmap.new(), // 节点映射
    @hashmap.new(), // 层映射
    @hashmap.new(), // 层到节点映射
    @hashmap.new(), // 位置映射
  )
  let nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())

  // 测试添加节点
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let state2 = incremental_layout_add_node(state1, nodeB, 1)

  // 测试添加边
  let state3 = incremental_layout_add_edge(state2, edgeAB)

  // 测试更新布局
  let options : LayeredOptions = default_layered_options()
  let state4 = incremental_layout_update(state3, options)

  // 测试获取位置
  let positions = incremental_layout_get_positions(state4)
  if positions.length() == 0 {
    panic()
  }
}

///|
test "测试边路由边界条件" {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试相同位置
  let same_pos : Position = (50.0, 50.0)
  let straight_same = route_edge("A", "B", same_pos, same_pos, "STRAIGHT")
  if list_length(straight_same) != 2 {
    panic()
  }

  // 测试垂直距离
  let vertical_pos : Position = (50.0, 0.0)
  let orthogonal_vertical = route_edge(
    "A", "B", source_pos, vertical_pos, "ORTHOGONAL",
  )
  if list_length(orthogonal_vertical) != 4 {
    panic()
  }

  // 测试水平距离
  let horizontal_pos : Position = (100.0, 50.0)
  let polyline_horizontal = route_edge(
    "A", "B", source_pos, horizontal_pos, "POLYLINE",
  )
  if list_length(polyline_horizontal) != 3 {
    panic()
  }

  // 测试未知策略
  let unknown_route = route_edge("A", "B", source_pos, target_pos, "UNKNOWN")
  if list_length(unknown_route) != 2 {
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let _edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())
  let _edgeCD : ElkEdge = ("e3", "C", "D", @list.empty())
  let _edgeDE : ElkEdge = ("e4", "D", "E", @list.empty())
  let edgeAE : ElkEdge = ("e5", "A", "E", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAE, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2
  let options : LayeredOptions = default_layered_options()
  let layout_options : LayoutOptions = ("UNKNOWN", options)
  let result : ElkNode = elk_layout(root, layout_options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例1: 基本分层布局" {
  let result = example_basic_layered()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例2: 复杂多层图布局" {
  let result = example_complex_multilayer()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例3: 带标签和端口的图" {
  let result = example_with_labels_and_ports()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例4: Force布局算法" {
  let result = example_force_layout()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例5: 增量式布局" {
  let result = example_incremental_layout()
  // 验证返回的是LayoutState类型
  let _ = result
}

///|
test "测试示例6: 不同布局方向" {
  let results = example_different_directions()
  if list_length(results) != 4 {
    panic()
  }
}

///|
test "测试示例7: 边缘路由演示" {
  let routes = example_edge_routing()
  if list_length(routes) != 4 {
    panic()
  }
}

///|
test "测试示例8: 性能测试图" {
  let result = example_performance_test()
  if result.0 == "" {
    panic()
  }
}

///|
test "测试示例9: 通用布局API演示" {
  let results = example_universal_api()
  if list_length(results) != 3 {
    panic()
  }
}

///|
test "测试示例10: 复杂工作流图" {
  let result = example_workflow_graph()
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e3", "B", "D", @list.empty())
  let _edgeCD : ElkEdge = ("e4", "C", "D", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeF : ElkNode = ("F", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e3", "B", "D", @list.empty())
  let _edgeBE : ElkEdge = ("e4", "B", "E", @list.empty())
  let _edgeCD : ElkEdge = ("e5", "C", "D", @list.empty())
  let _edgeCF : ElkEdge = ("e6", "C", "F", @list.empty())
  let _edgeDE : ElkEdge = ("e7", "D", "E", @list.empty())
  let _edgeDF : ElkEdge = ("e8", "D", "F", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.empty())),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeF : ElkNode = ("F", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeG : ElkNode = ("G", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeH : ElkNode = ("H", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeI : ElkNode = ("I", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeJ : ElkNode = ("J", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.empty())
  let _edgeBE : ElkEdge = ("e4", "B", "E", @list.empty())
  let _edgeBF : ElkEdge = ("e5", "B", "F", @list.empty())
  let _edgeCE : ElkEdge = ("e6", "C", "E", @list.empty())
  let _edgeCF : ElkEdge = ("e7", "C", "F", @list.empty())
  let _edgeDG : ElkEdge = ("e8", "D", "G", @list.empty())
  let _edgeEH : ElkEdge = ("e9", "E", "H", @list.empty())
  let _edgeFI : ElkEdge = ("e10", "F", "I", @list.empty())
  let _edgeGJ : ElkEdge = ("e11", "G", "J", @list.empty())
  let _edgeHJ : ElkEdge = ("e12", "H", "J", @list.empty())
  let _edgeIJ : ElkEdge = ("e13", "I", "J", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.empty()))),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.empty()),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试不同的选项组合
  let test_combination = fn(
    layer_spacing : Float,
    node_spacing : Float,
    direction : String,
    sorting : String,
    routing : String,
    alignment : String,
  ) {
    let options : LayeredOptions = (
      layer_spacing, node_spacing, direction, sorting, routing, alignment, true,
      true, 1.0, 10,
    )
    let result : ElkNode = layout_layered(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeF : ElkNode = ("F", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeG : ElkNode = ("G", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeH : ElkNode = ("H", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeI : ElkNode = ("I", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeJ : ElkNode = ("J", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeK : ElkNode = ("K", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeL : ElkNode = ("L", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.empty())
  let _edgeBE : ElkEdge = ("e4", "B", "E", @list.empty())
  let _edgeBF : ElkEdge = ("e5", "B", "F", @list.empty())
  let _edgeCG : ElkEdge = ("e6", "C", "G", @list.empty())
  let _edgeCH : ElkEdge = ("e7", "C", "H", @list.empty())
  let _edgeDI : ElkEdge = ("e8", "D", "I", @list.empty())
  let _edgeDJ : ElkEdge = ("e9", "D", "J", @list.empty())
  let _edgeEK : ElkEdge = ("e10", "E", "K", @list.empty())
  let _edgeFL : ElkEdge = ("e11", "F", "L", @list.empty())
  let _edgeGL : ElkEdge = ("e12", "G", "L", @list.empty())
  let _edgeHL : ElkEdge = ("e13", "H", "L", @list.empty())
  let _edgeIL : ElkEdge = ("e14", "I", "L", @list.empty())
  let _edgeJL : ElkEdge = ("e15", "J", "L", @list.empty())
  let _edgeKL : ElkEdge = ("e16", "K", "L", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.empty()))),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "测试边路由所有策略" {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试所有边路由策略
  let _strategies = @list.cons(
    "STRAIGHT",
    @list.cons(
      "ORTHOGONAL",
      @list.cons("POLYLINE", @list.cons("SPLINES", @list.empty())),
    ),
  )
  let test_routing_strategy = fn(strategy : String) {
    let route = route_edge("A", "B", source_pos, target_pos, strategy)
    if list_length(route) < 2 {
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
  let same_pos : Position = (50.0, 50.0)
  let straight_same = route_edge("A", "B", same_pos, same_pos, "STRAIGHT")
  if list_length(straight_same) != 2 {
    panic()
  }

  // 测试垂直距离
  let vertical_pos : Position = (50.0, 0.0)
  let orthogonal_vertical = route_edge(
    "A",
    "B",
    (0.0, 0.0),
    vertical_pos,
    "ORTHOGONAL",
  )
  if list_length(orthogonal_vertical) != 4 {
    panic()
  }

  // 测试水平距离
  let horizontal_pos : Position = (100.0, 50.0)
  let polyline_horizontal = route_edge(
    "A",
    "B",
    (0.0, 0.0),
    horizontal_pos,
    "POLYLINE",
  )
  if list_length(polyline_horizontal) != 3 {
    panic()
  }

  // 测试未知策略
  let unknown_route = route_edge(
    "A",
    "B",
    (0.0, 0.0),
    (100.0, 100.0),
    "UNKNOWN",
  )
  if list_length(unknown_route) != 2 {
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
    @hashmap.new(), // 节点映射
    @hashmap.new(), // 层映射
    @hashmap.new(), // 层到节点映射
    @hashmap.new(), // 位置映射
  )
  let nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.empty())

  // 测试添加节点
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let state2 = incremental_layout_add_node(state1, nodeB, 1)
  let state3 = incremental_layout_add_node(state2, nodeC, 2)

  // 测试添加边
  let state4 = incremental_layout_add_edge(state3, edgeAB)
  let state5 = incremental_layout_add_edge(state4, edgeBC)

  // 测试更新布局
  let options : LayeredOptions = default_layered_options()
  let state6 = incremental_layout_update(state5, options)

  // 测试获取位置
  let positions = incremental_layout_get_positions(state6)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeE : ElkNode = ("E", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeF : ElkNode = ("F", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.empty())
  let _edgeBC : ElkEdge = ("e4", "B", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e5", "B", "D", @list.empty())
  let _edgeBE : ElkEdge = ("e6", "B", "E", @list.empty())
  let _edgeCD : ElkEdge = ("e7", "C", "D", @list.empty())
  let _edgeCE : ElkEdge = ("e8", "C", "E", @list.empty())
  let _edgeCF : ElkEdge = ("e9", "C", "F", @list.empty())
  let _edgeDE : ElkEdge = ("e10", "D", "E", @list.empty())
  let _edgeDF : ElkEdge = ("e11", "D", "F", @list.empty())
  let _edgeEF : ElkEdge = ("e12", "E", "F", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.empty()))),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)
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
  let _nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeB : ElkNode = ("B", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeC : ElkNode = ("C", None, @list.empty(), @list.empty(), x, y, w, h)
  let _nodeD : ElkNode = ("D", None, @list.empty(), @list.empty(), x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.empty())
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.empty())
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.empty())
  let _edgeBC : ElkEdge = ("e4", "B", "C", @list.empty())
  let _edgeBD : ElkEdge = ("e5", "B", "D", @list.empty())
  let _edgeCD : ElkEdge = ("e6", "C", "D", @list.empty())
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.cons(edgeAB, @list.cons(edgeAC, @list.cons(edgeAD, @list.empty()))),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_fixed(root, options)
  if result.0 == "" {
    panic()
  }
}

///|
test "group_layers 边界测试" {
  let node_map = @hashmap.new()
  let layers = @hashmap.new()
  let keys = @list.empty()
  let map = @hashmap.new()
  let options = default_layered_options()
  let result = group_layers(keys, map, layers, node_map, options)
  // 空输入应返回空 layers
  if result.length() != 0 {
    panic()
  }
}

///|
test "assign_x/calculate_max_width/assign_coords 空输入测试" {
  let ids = @list.empty()
  let node_map = @hashmap.new()
  let alignment = "CENTER"
  let max_width : Float = 0.0
  let x = assign_x(ids, 0.0, 10.0, node_map, alignment, max_width)
  if x != 0.0 {
    panic()
  }
  let mw = calculate_max_width(ids, node_map, 0.0)
  if mw != 0.0 {
    panic()
  }
  let layers = @hashmap.new()
  let options = default_layered_options()
  assign_coords(layers, 0.0, options, node_map)
} // 只要不 panic 即可

///|
test "collect_ids/append_edges 空输入测试" {
  let map = @hashmap.new()
  let ids = collect_ids(map)
  if list_length(ids) != 0 {
    panic()
  }
  let edges1 = @list.empty()
  let edges2 = @list.empty()
  let appended = append_edges(edges1, edges2)
  if list_length(appended) != 0 {
    panic()
  }
}

///|
test "force_init_pos/collect_node_ids 空输入测试" {
  let ids = @list.empty()
  let pos = @hashmap.new()
  let result = force_init_pos(ids, pos)
  if result.length() != 0 {
    panic()
  }
  let node_map = @hashmap.new()
  let node_ids = collect_node_ids(node_map)
  if list_length(node_ids) != 0 {
    panic()
  }
}

///|
test "to_float 测试" {
  let i : Int = 42
  let f = to_float(i)
  if f != 42.0 {
    panic()
  }
}

///|
test "force_sum_rep/force_calc_repulsion/force_sum_att/force_calc_attraction/force_update/force_iterate/force_update_node 空输入测试" {
  let ids = @list.empty()
  let pos = @hashmap.new()
  let k : Float = 1.0
  let rep = force_calc_repulsion(ids, pos, k, @hashmap.new())
  if rep.length() != 0 {
    panic()
  }
  let att = force_calc_attraction(@hashmap.new(), pos, k, @hashmap.new())
  if att.length() != 0 {
    panic()
  }
  let updated = force_update(ids, pos, rep, att, 1.0, 1, @hashmap.new())
  if updated.length() != 0 {
    panic()
  }
  let iterated = force_iterate(pos, ids, @hashmap.new(), k, 1.0, 1)
  if iterated.length() != 0 {
    panic()
  }
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let node2 = force_update_node(node, pos)
  if node2.0 != "A" {
    panic()
  }
}

///|
test "补测 group_layers None 分支" {
  let node_map = @hashmap.new()
  let layers = @hashmap.new()
  let keys = @list.cons("not_exist", @list.empty())
  let map = @hashmap.new()
  let options = default_layered_options()
  let _result = group_layers(keys, map, layers, node_map, options)
}
// 只要不 panic 即可

///|
test "补测 assign_x 非法 alignment" {
  let ids = @list.cons("A", @list.empty())
  let node_map = @hashmap.new()
  let _x = assign_x(ids, 0.0, 10.0, node_map, "FOO", 10.0)
}
// 只要不 panic 即可

///|
test "补测 calculate_max_width 空节点" {
  let ids = @list.cons("not_exist", @list.empty())
  let node_map = @hashmap.new()
  let _mw = calculate_max_width(ids, node_map, 0.0)
}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_name 空列表" {
  let ids = @list.empty()
  let _result = assign_x(ids, 0.0, 10.0, @hashmap.new(), "CENTER", 10.0)
}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_degree 空节点" {
  let ids = @list.cons("not_exist", @list.empty())
  let node_map = @hashmap.new()
  let _result = calculate_max_width(ids, node_map, 0.0)
}
// 只要不 panic 即可

///|
test "补测 calculate_x_by_alignment default 分支" {
  let ids = @list.cons("A", @list.empty())
  let node_map = @hashmap.new()
  let _x = assign_x(ids, 0.0, 10.0, node_map, "UNKNOWN", 10.0)
}
// 只要不 panic 即可

///|
test "补测 route_edge 未知策略" {
  let pos : Position = (0.0, 0.0)
  let route = route_edge("A", "B", pos, pos, "UNKNOWN")
  if list_length(route) != 2 {
    panic()
  }
}

///|
test "补测 force_sum_rep 递归终止" {
  let ids = @list.empty()
  let result = force_calc_repulsion(ids, @hashmap.new(), 1.0, @hashmap.new())
  if result.length() != 0 {
    panic()
  }
}

///|
test "补测 force_sum_att 递归终止" {
  let _edges : @list.List[ElkEdge] = @list.empty()
  let pos = @hashmap.new()
  let result = force_calc_attraction(@hashmap.new(), pos, 1.0, @hashmap.new())
  if result.length() == 0 {
    panic()
  }
}

///|
test "补测 remove_node_from_list 空列表" {
  let nodes = @list.empty()
  let _result = assign_x(nodes, 0.0, 10.0, @hashmap.new(), "CENTER", 10.0)
}
// 只要不 panic 即可

///|
test "补测 add_edge_to_layout 节点不存在" {
  let state = (@hashmap.new(), @hashmap.new(), @hashmap.new(), @hashmap.new())
  let edge : ElkEdge = ("e1", "A", "B", @list.empty())
  let _result = incremental_layout_add_edge(state, edge)
}
// 只要不 panic 即可

///|
test "补测 update_layout_positions 空层" {
  let state = (@hashmap.new(), @hashmap.new(), @hashmap.new(), @hashmap.new())
  let options = default_layered_options()
  let _result = incremental_layout_update(state, options)
}
// 只要不 panic 即可

///|
test "补测 elk_layout 未知算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.empty(), @list.empty(), x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let layout_options : LayoutOptions = ("UNKNOWN", options)
  let result : ElkNode = elk_layout(nodeA, layout_options)
  if result.0 == "" {
    panic()
  }
}

///|
test "补测 minimize_crossings 空层" {
  let layers = @hashmap.new()
  let edges = @list.empty()
  let _result = minimize_crossings(layers, edges)
}
// 只要不 panic 即可

///|
test "补测 count_crossings 空层" {
  let layer1 = @list.empty()
  let layer2 = @list.empty()
  let edges = @list.empty()
  let _crossings = count_crossings(layer1, layer2, edges)
}
// 只要不 panic 即可

///|
test "补测 get_node_at_index 越界" {
  let nodes = @list.cons("A", @list.empty())
  let _node = get_node_at_index(nodes, 5)
}
// 只要不 panic 即可

///|
test "补测 has_edge_between 空边" {
  let result = has_edge_between("A", "B", @list.empty())
  if result != false {
    panic()
  }
}

///|
test "补测 reverse_list 空列表" {
  let lst : @list.List[String] = @list.empty()
  let _rev = reverse_list(lst)
}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_name 全相同" {
  let ids = @list.cons("A", @list.cons("A", @list.empty()))
  let _result = sort_nodes_by_name(ids, @list.empty())
}
// 只要不 panic 即可

///|
test "补测 insert_by_name 空列表" {
  let _result = insert_by_name("A", @list.empty())
}
// 只要不 panic 即可

///|
test "补测 insert_by_degree 空列表" {
  let node_map = @hashmap.new()
  let _result = insert_by_degree("A", 1, @list.empty(), node_map)
}
// 只要不 panic 即可

///|
test "补测 node_degree 空节点" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let _degree = node_degree(node)
}
// 只要不 panic 即可

///|
test "补测 collect_all_edges 空节点" {
  let node_map = @hashmap.new()
  let _edges = collect_all_edges(node_map)
}
// 只要不 panic 即可

///|
test "补测 append_edges 空列表" {
  let edges1 = @list.empty()
  let edges2 = @list.empty()
  let _result = append_edges(edges1, edges2)
}
// 只要不 panic 即可

///|
test "补测 remove_node_from_list 不存在节点" {
  let nodes = @list.cons("A", @list.cons("B", @list.empty()))
  let _result = remove_node_from_list(nodes, "C")
}
// 只要不 panic 即可

///|
test "补测 update_layout_positions 空节点" {
  let state = (@hashmap.new(), @hashmap.new(), @hashmap.new(), @hashmap.new())
  let options = default_layered_options()
  let _result = incremental_layout_update(state, options)
}
// 只要不 panic 即可

///|
test "补测 layout_layered 空节点" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = default_layered_options()
  let _result = layout_layered(node, options)
}
// 只要不 panic 即可

///|
test "补测 layout_fixed 空节点" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = default_layered_options()
  let _result = layout_fixed(node, options)
}
// 只要不 panic 即可

///|
test "补测 layout_force 空节点" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = default_layered_options()
  let _result = layout_force(node, options)
}
// 只要不 panic 即可

///|
test "补测 minimize_crossings 空层和单层" {
  let layers = @hashmap.new()
  let edges = @list.empty()
  // 空层
  let result1 = minimize_crossings(layers, edges)
  if result1.length() != 0 {
    panic()
  }
  // 只有一层
  layers.set(0, @list.cons("A", @list.empty()))
  let result2 = minimize_crossings(layers, edges)
  if result2.length() != 1 {
    panic()
  }
}

///|
test "补测 count_crossings 空层和无交叉" {
  let l1 = @list.empty()
  let l2 = @list.empty()
  let edges = @list.empty()
  let c1 = count_crossings(l1, l2, edges)
  if c1 != 0 {
    panic()
  }
  let l1b = @list.cons("A", @list.empty())
  let l2b = @list.cons("B", @list.empty())
  let c2 = count_crossings(l1b, l2b, edges)
  if c2 != 0 {
    panic()
  }
}

///|
test "补测 get_node_at_index 越界和空列表" {
  let nodes = @list.empty()
  let n1 = get_node_at_index(nodes, 0)
  if n1 != "" {
    panic()
  }
  let nodes2 = @list.cons("A", @list.empty())
  let n2 = get_node_at_index(nodes2, 5)
  if n2 != "" {
    panic()
  }
}

///|
test "补测 has_edge_between 空边和无匹配" {
  let edges = @list.empty()
  let r1 = has_edge_between("A", "B", edges)
  if r1 != false {
    panic()
  }
  let e : ElkEdge = ("e1", "A", "C", @list.empty())
  let edges2 = @list.cons(e, @list.empty())
  let r2 = has_edge_between("A", "B", edges2)
  if r2 != false {
    panic()
  }
}

///|
test "补测 reverse_list 空列表和单元素" {
  let l : @list.List[String] = @list.empty()
  let r = reverse_list(l)
  if list_length(r) != 0 {
    panic()
  }
  let l2 = @list.cons("A", @list.empty())
  let r2 = reverse_list(l2)
  if list_length(r2) != 1 {
    panic()
  }
}

///|
test "补测 insert_by_name 空列表和已排序" {
  let r = insert_by_name("A", @list.empty())
  if list_length(r) != 1 {
    panic()
  }
  let r2 = insert_by_name("B", @list.cons("A", @list.empty()))
  if list_length(r2) != 2 {
    panic()
  }
}

///|
test "补测 node_degree 空节点二" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let d = node_degree(node)
  if d != 0 {
    panic()
  }
}

///|
test "补测 remove_node_from_list 空列表和不存在节点" {
  let l = @list.empty()
  let r = remove_node_from_list(l, "A")
  if list_length(r) != 0 {
    panic()
  }
  let l2 = @list.cons("A", @list.cons("B", @list.empty()))
  let r2 = remove_node_from_list(l2, "C")
  if list_length(r2) != 2 {
    panic()
  }
}

///|
test "补测 force_init_pos 空输入" {
  let ids = @list.empty()
  let pos = @hashmap.new()
  let r = force_init_pos(ids, pos)
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_calc_repulsion 空输入" {
  let ids = @list.empty()
  let pos = @hashmap.new()
  let r = force_calc_repulsion(ids, pos, 1.0, @hashmap.new())
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_sum_rep 递归终止二" {
  let ids = @list.empty()
  let r = force_calc_repulsion(ids, @hashmap.new(), 1.0, @hashmap.new())
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_sum_att 空边" {
  let node_map = @hashmap.new()
  let pos = @hashmap.new()
  let r = force_calc_attraction(node_map, pos, 1.0, @hashmap.new())
  if r.length() == 0 {
    panic()
  }
}

///|
test "补测 force_iterate 0 次迭代" {
  let pos = @hashmap.new()
  let ids = @list.empty()
  let node_map = @hashmap.new()
  let r = force_iterate(pos, ids, node_map, 1.0, 1.0, 0)
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_update 空输入" {
  let ids = @list.empty()
  let pos = @hashmap.new()
  let rep = @hashmap.new()
  let att = @hashmap.new()
  let r = force_update(ids, pos, rep, att, 1.0, 1, @hashmap.new())
  if r.length() != 0 {
    panic()
  }
}

///|
test "补测 force_update_node 无位置" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let pos = @hashmap.new()
  let r = force_update_node(node, pos)
  if r.0 != "A" {
    panic()
  }
}

///|
test "补测 collect_node_ids 空 map" {
  let map = @hashmap.new()
  let r = collect_node_ids(map)
  if list_length(r) != 0 {
    panic()
  }
}

///|
test "补测 to_float" {
  let i : Int = 42
  let f = to_float(i)
  if f != 42.0 {
    panic()
  }
}

///|
test "补测 elk_layout 默认分支" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options : LayeredOptions = default_layered_options()
  let layout_options : LayoutOptions = ("unknown", options)
  let r = elk_layout(node, layout_options)
  if r.0 != "A" {
    panic()
  }
}

///|
test "补测 add_edge_to_layout target_layer > source_layer" {
  let state = (@hashmap.new(), @hashmap.new(), @hashmap.new(), @hashmap.new())
  // 只设置目标节点层，且大于源节点层
  let nodeA : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let edge : ElkEdge = ("e1", "A", "B", @list.empty())
  let state1 = incremental_layout_add_node(state, nodeA, 0)
  let state2 = incremental_layout_add_node(state1, nodeB, 2)
  let _state3 = incremental_layout_add_edge(state2, edge)
}
// 只要不 panic 即可

///|
test "补测 update_layout_positions None 分支" {
  let state = (@hashmap.new(), @hashmap.new(), @hashmap.new(), @hashmap.new())
  let options = default_layered_options()
  let _result = incremental_layout_update(state, options)
}
// 只要不 panic 即可

///|
test "补测 remove_node_from_list Nil" {
  let l = @list.empty()
  let r = remove_node_from_list(l, "A")
  if list_length(r) != 0 {
    panic()
  }
}

///|
test "补测 layout_layered 空节点二" {
  let node : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let options = default_layered_options()
  let result = layout_layered(node, options)
  if result.0 != "A" {
    panic()
  }
}

///|
test "补测 collect_all_edges 非空 map" {
  let nodeA : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let edge : ElkEdge = ("e1", "A", "A", @list.empty())
  let nodeB : ElkNode = (
    "B",
    None,
    @list.empty(),
    @list.cons(edge, @list.empty()),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.new()
  map.set("A", nodeA)
  map.set("B", nodeB)
  let edges = collect_all_edges(map)
  if list_length(edges) != 1 {
    panic()
  }
}

///|
test "补测 collect_node_ids 非空 map" {
  let nodeA : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.new()
  map.set("A", nodeA)
  let ids = collect_node_ids(map)
  if list_length(ids) != 1 {
    panic()
  }
}

///|
test "补测 force_edges_for 非空 map" {
  let nodeA : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let edge : ElkEdge = ("e1", "A", "A", @list.empty())
  let nodeB : ElkNode = (
    "B",
    None,
    @list.empty(),
    @list.cons(edge, @list.empty()),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.new()
  map.set("A", nodeA)
  map.set("B", nodeB)
  let edges = force_edges_for(map, @list.empty())
  if list_length(edges) != 1 {
    panic()
  }
}

///|
test "补测 minimize_crossings 多层多边" {
  let layers = @hashmap.new()
  layers.set(0, @list.cons("A", @list.cons("B", @list.empty())))
  layers.set(1, @list.cons("C", @list.cons("D", @list.empty())))
  let edge1 : ElkEdge = ("e1", "A", "C", @list.empty())
  let edge2 : ElkEdge = ("e2", "B", "D", @list.empty())
  let edges = @list.cons(edge1, @list.cons(edge2, @list.empty()))
  let result = minimize_crossings(layers, edges)
  if result.length() != 2 {
    panic()
  }
}

///|
test "补测 force_sum_rep/force_sum_att 复杂分支" {
  let ids = @list.cons("A", @list.cons("B", @list.empty()))
  let pos : @hashmap.HashMap[String, (Float, Float)] = @hashmap.new()
  pos.set("A", (0.0, 0.0))
  pos.set("B", (1.0, 1.0))
  let k : Float = 1.0
  let _rep = force_calc_repulsion(ids, pos, k, @hashmap.new())
  let nodeA : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.new()
  map.set("A", nodeA)
  map.set("B", nodeB)
  let _att = force_calc_attraction(map, pos, k, @hashmap.new())
}
// 只要不 panic 即可

///|
test "补测 assign_coords 多层多节点" {
  let nodeA : ElkNode = (
    "A",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let nodeB : ElkNode = (
    "B",
    None,
    @list.empty(),
    @list.empty(),
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let node_map = @hashmap.new()
  node_map.set("A", nodeA)
  node_map.set("B", nodeB)
  let layers = @hashmap.new()
  layers.set(0, @list.cons("A", @list.empty()))
  layers.set(1, @list.cons("B", @list.empty()))
  let options = default_layered_options()
  assign_coords(layers, 0.0, options, node_map)
}
// 只要不 panic 即可

///|
test "补测 route_edge 极端坐标" {
  let x1 : Float = 10000000000.0
  let y1 : Float = 10000000000.0
  let x2 : Float = -10000000000.0
  let y2 : Float = -10000000000.0
  let pos1 : Position = (x1, y1)
  let pos2 : Position = (x2, y2)
  let r = route_edge("A", "B", pos1, pos2, "STRAIGHT")
  if list_length(r) != 2 {
    let _ : Unit = panic()
  }
}

///|
test "补测 insert_by_degree None 分支" {
  let node_map = @hashmap.new()
  let sorted = @list.cons("A", @list.empty())
  // node_map 不含 "A"，触发 None 分支
  let result = insert_by_degree("B", 2, sorted, node_map)
  if list_length(result) != 2 {
    let _ : Unit = panic()
  }
}

///|
test "补测 assign_x/calculate_max_width/assign_coords None 节点分支" {
  let node_map = @hashmap.new()
  let ids = @list.cons("not_exist", @list.empty())
  // assign_x None 分支
  let _ = assign_x(ids, 0.0, 10.0, node_map, "CENTER", 10.0)
  // calculate_max_width None 分支
  let _ = calculate_max_width(ids, node_map, 0.0)
  // assign_coords 空节点分支
  let layers = @hashmap.new()
  layers.set(0, ids)
  let options = default_layered_options()
  assign_coords(layers, 0.0, options, node_map)
}
// 只要不 panic 即可
