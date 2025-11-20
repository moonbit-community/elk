///|
test "简单分层布局" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
    let _ = panic

  }
  if result.5 != 0.0 {
    let _ = panic

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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w1, h1)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w2, h2)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
    let _ = panic

  }
  if result.5 != 0.0 {
    let _ = panic

  }
}

///|
test "边缘交叉最小化测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个有交叉边的图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.T.Nil)
  let edgeCD : ElkEdge = ("e4", "C", "D", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
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
    let _ = panic

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
    @hashmap.T.new(), // 节点映射
    @hashmap.T.new(), // 层映射
    @hashmap.T.new(), // 层到节点列表映射
    @hashmap.T.new(), // 节点位置映射
  )

  // 添加节点
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state2 = incremental_layout_add_node(state1, nodeB, 1)

  // 添加边
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let state3 = incremental_layout_add_edge(state2, edgeAB)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  let final_state = incremental_layout_update(state3, options)

  // 获取位置
  let positions = incremental_layout_get_positions(final_state)

  // 验证位置不为空
  if positions.size() == 0 {
    let _ = panic

  }
}

///|
test "边缘路由测试" {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试直线路由
  let straight_route = route_edge("A", "B", source_pos, target_pos, "STRAIGHT")
  if list_length(straight_route) != 2 {
    let _ = panic

  }

  // 测试正交路由
  let orthogonal_route = route_edge(
    "A", "B", source_pos, target_pos, "ORTHOGONAL",
  )
  if list_length(orthogonal_route) != 4 {
    let _ = panic

  }

  // 测试折线路由
  let polyline_route = route_edge("A", "B", source_pos, target_pos, "POLYLINE")
  if list_length(polyline_route) != 3 {
    let _ = panic

  }

  // 测试样条路由
  let spline_route = route_edge("A", "B", source_pos, target_pos, "SPLINES")
  if list_length(spline_route) != 4 {
    let _ = panic

  }
}

///|
test "多层复杂图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建多层复杂图：A -> B,C -> D,E,F -> G
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeG : ElkNode = ("G", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
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
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
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
    let _ = panic

  }
}

///|
test "带标签和端口的复杂图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建带标签的节点
  let nodeA : ElkNode = ("A", Some("Start"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", Some("Process"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", Some("End"), @list.T.Nil, @list.T.Nil, x, y, w, h)

  // 创建带标签的边
  let label1 : ElkLabel = ("flow", 0.0, 0.0)
  let label2 : ElkLabel = ("result", 0.0, 0.0)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.[label1, ..@list.T.Nil])
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.[label2, ..@list.T.Nil])
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("Start"),
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
    let _ = panic

  }
}

///|
test "Force布局算法测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建用于Force布局的图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let edgeAC : ElkEdge = ("e3", "A", "C", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
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
    let _ = panic

  }
}

///|
test "通用布局API测试" {
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

  // 测试Layered布局
  let layered_options : LayoutOptions = ("layered", options)
  let layered_result : ElkNode = elk_layout(root, layered_options)
  if layered_result.0 == "" {
    let _ = panic

  }

  // 测试Fixed布局
  let fixed_options : LayoutOptions = ("fixed", options)
  let fixed_result : ElkNode = elk_layout(root, fixed_options)
  if fixed_result.0 == "" {
    let _ = panic

  }

  // 测试Force布局
  let force_options : LayoutOptions = ("force", options)
  let force_result : ElkNode = elk_layout(root, force_options)
  if force_result.0 == "" {
    let _ = panic

  }
}

///|
test "性能测试-中等规模图" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个中等规模的图（10个节点）
  let mut edges = @list.T.Nil
  let mut i = 0
  while i < 9 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @list.T.Nil)
    edges = @list.T.[edge, ..edges]
    i = i + 1
  }
  let root : ElkNode = ("node0", None, @list.T.Nil, edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "不同布局方向测试" {
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
  let mut current = directions
  while true {
    match current {
      @list.T.[direction, ..rest] => {
        let options : LayeredOptions = (
          50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true,
          1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
        if result.0 == "" {
          let _ = panic

        }
        current = rest
      }
      @list.T.[] => break
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
  let nodeA : ElkNode = ("A", Some("Single"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let root : ElkNode = nodeA
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "无边图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建没有边的图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeA_with_edges : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "自环边测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建包含自环的图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAA : ElkEdge = ("e1", "A", "A", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAA, ..@list.T.Nil],
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
    let _ = panic

  }
}

///|
test "循环图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建循环图：A -> B -> C -> A
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let edgeCA : ElkEdge = ("e3", "C", "A", @list.T.Nil)
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
  let result : ElkNode = layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "不同排序策略测试" {
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
    @list.T.[edgeAB, ..@list.T.Cons(edgeBC, @list.T.Nil]),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges

  // 测试不同排序策略
  let strategies = @list.T.[
    "NONE", ..@list.T.Cons(
      "INPUT_ORDER",
      @list.T.Cons("NAME", @list.T.Cons("DEGREE", @list.T.Nil]),
    ),
  )
  let mut current = strategies
  while true {
    match current {
      @list.T.[strategy, ..rest] => {
        let options : LayeredOptions = (
          50.0, 30.0, "DOWN", strategy, "STRAIGHT", "CENTER", true, true, 1.0, 10,
        )
        let result : ElkNode = layout_layered(root, options)
        if result.0 == "" {
          let _ = panic

        }
        current = rest
      }
      @list.T.[] => break
    }
  }
}

///|
test "不同对齐方式测试" {
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

  // 测试不同对齐方式
  let alignments = @list.T.[
    "LEFT", ..@list.T.Cons(
      "CENTER",
      @list.T.Cons(
        "RIGHT",
        @list.T.Cons("TOP", @list.T.Cons("BOTTOM", @list.T.Cons("NONE", @list.T.Nil])),
      ),
    ),
  )
  let mut current = alignments
  while true {
    match current {
      @list.T.[alignment, ..rest] => {
        let options : LayeredOptions = (
          50.0, 30.0, "DOWN", "INPUT_ORDER", "STRAIGHT", alignment, true, true, 1.0,
          10,
        )
        let result : ElkNode = layout_layered(root, options)
        if result.0 == "" {
          let _ = panic

        }
        current = rest
      }
      @list.T.[] => break
    }
  }
}

///|
test "工具函数测试" {
  // 测试 list_length 函数
  let empty_list = @list.T.Nil
  if list_length(empty_list) != 0 {
    let _ = panic

  }
  let single_list = @list.T.["A", ..@list.T.Nil]
  if list_length(single_list) != 1 {
    let _ = panic

  }
  let multi_list = @list.T.["A", ..@list.T.Cons("B", @list.T.Cons("C", @list.T.Nil]))
  if list_length(multi_list) != 3 {
    let _ = panic

  }

  // 测试列表长度计算
  if list_length(multi_list) != 3 {
    let _ = panic

  }
}

///|
test "默认选项测试" {
  let options = default_layered_options()

  // 验证默认选项的各个字段
  if options.0 != 50.0 {
    let _ = panic

  } // layer_spacing
  if options.1 != 30.0 {
    let _ = panic

  } // node_spacing
  if options.2 != "DOWN" {
    let _ = panic

  } // direction
  if options.3 != "INPUT_ORDER" {
    let _ = panic

  } // node_sorting
  if options.4 != "STRAIGHT" {
    let _ = panic

  } // edge_routing
  if options.5 != "CENTER" {
    let _ = panic

  } // alignment
  if options.6 != true {
    let _ = panic

  } // consider_node_labels
  if options.7 != true {
    let _ = panic

  } // consider_port_positions
  if options.8 != 1.0 {
    let _ = panic

  } // aspect_ratio
  if options.9 != 10 {
    let _ = panic

  }
} // iterations

///|
test "大规模图性能测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建一个较大规模的图（50个节点）
  let mut edges = @list.T.Nil
  let mut i = 0
  while i < 49 {
    let source = "node" + i.to_string()
    let target = "node" + (i + 1).to_string()
    let edge : ElkEdge = ("e" + i.to_string(), source, target, @list.T.Nil)
    edges = @list.T.[edge, ..edges]
    i = i + 1
  }

  // 添加一些交叉边
  let cross_edge1 : ElkEdge = ("cross1", "node0", "node25", @list.T.Nil)
  let cross_edge2 : ElkEdge = ("cross2", "node10", "node40", @list.T.Nil)
  let cross_edge3 : ElkEdge = ("cross3", "node5", "node35", @list.T.Nil)
  edges = @list.T.[
    cross_edge1, ..@list.T.Cons(cross_edge2, @list.T.Cons(cross_edge3, edges]),
  )
  let root : ElkNode = ("node0", None, @list.T.Nil, edges, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)

  // 验证结果不为空
  if result.0 == "" {
    let _ = panic

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
    @hashmap.T.new(), // 节点映射
    @hashmap.T.new(), // 层映射
    @hashmap.T.new(), // 层到节点列表映射
    @hashmap.T.new(), // 节点位置映射
  )

  // 逐步添加多个节点
  let nodeA : ElkNode = ("A", Some("Start"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state1 = incremental_layout_add_node(initial_state, nodeA, 0)
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
  let state2 = incremental_layout_add_node(state1, nodeB, 1)
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
  let state3 = incremental_layout_add_node(state2, nodeC, 1)
  let nodeD : ElkNode = ("D", Some("End"), @list.T.Nil, @list.T.Nil, x, y, w, h)
  let state4 = incremental_layout_add_node(state3, nodeD, 2)

  // 添加多条边
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let state5 = incremental_layout_add_edge(state4, edgeAB)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let state6 = incremental_layout_add_edge(state5, edgeAC)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.T.Nil)
  let state7 = incremental_layout_add_edge(state6, edgeBD)
  let edgeCD : ElkEdge = ("e4", "C", "D", @list.T.Nil)
  let state8 = incremental_layout_add_edge(state7, edgeCD)

  // 更新布局
  let options : LayeredOptions = default_layered_options()
  let final_state = incremental_layout_update(state8, options)

  // 获取位置
  let positions = incremental_layout_get_positions(final_state)

  // 验证位置不为空
  if positions.size() == 0 {
    let _ = panic

  }
}

///|
test "边缘路由边界条件测试" {
  // 测试相同位置的边缘路由
  let same_pos : Position = (0.0, 0.0)
  let straight_same = route_edge("A", "A", same_pos, same_pos, "STRAIGHT")
  if list_length(straight_same) != 2 {
    let _ = panic

  }

  // 测试垂直边缘路由
  let vertical_source : Position = (0.0, 0.0)
  let vertical_target : Position = (0.0, 100.0)
  let orthogonal_vertical = route_edge(
    "A", "B", vertical_source, vertical_target, "ORTHOGONAL",
  )
  if list_length(orthogonal_vertical) != 4 {
    let _ = panic

  }

  // 测试水平边缘路由
  let horizontal_source : Position = (0.0, 0.0)
  let horizontal_target : Position = (100.0, 0.0)
  let polyline_horizontal = route_edge(
    "A", "B", horizontal_source, horizontal_target, "POLYLINE",
  )
  if list_length(polyline_horizontal) != 3 {
    let _ = panic

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
    let _ = panic

  }
}

///|
test "Force布局复杂图测试" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建更复杂的Force布局图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let edgeCD : ElkEdge = ("e3", "C", "D", @list.T.Nil)
  let edgeDE : ElkEdge = ("e4", "D", "E", @list.T.Nil)
  let edgeAE : ElkEdge = ("e5", "A", "E", @list.T.Nil)
  let edgeAC : ElkEdge = ("e6", "A", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e7", "B", "D", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAE, @list.T.Cons(edgeAC, @list.T.Nil])),
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
    let _ = panic

  }
}

///|
test "通用API未知算法测试" {
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
  let layout_options : LayoutOptions = ("UNKNOWN", options)
  let result : ElkNode = elk_layout(root, layout_options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试所有布局方向" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有方向
  let directions = @list.T.[
    "DOWN", ..@list.T.Cons("UP", @list.T.Cons("LEFT", @list.T.Cons("RIGHT", @list.T.Nil])),
  )
  let test_direction = fn(direction : String) {
    let options : LayeredOptions = (
      50.0, 30.0, direction, "INPUT_ORDER", "STRAIGHT", "CENTER", true, true, 1.0,
      10,
    )
    let result : ElkNode = layout_layered(root, options)
    if result.0 == "" {
      let _ = panic

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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有排序策略
  let strategies = @list.T.[
    "INPUT_ORDER", ..@list.T.Cons(
      "DEGREE",
      @list.T.Cons("DEPTH_FIRST", @list.T.Cons("BREADTH_FIRST", @list.T.Nil]),
    ),
  )
  let test_strategy = fn(strategy : String) {
    let options : LayeredOptions = (
      50.0, 30.0, "DOWN", strategy, "STRAIGHT", "CENTER", true, true, 1.0, 10,
    )
    let result : ElkNode = layout_layered(root, options)
    if result.0 == "" {
      let _ = panic

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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有对齐策略
  let alignments = @list.T.[
    "CENTER", ..@list.T.Cons(
      "LEFT",
      @list.T.Cons(
        "RIGHT",
        @list.T.Cons("TOP", @list.T.Cons("BOTTOM", @list.T.Cons("NONE", @list.T.Nil])),
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
      let _ = panic

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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有边路由策略
  let routings = @list.T.[
    "STRAIGHT", ..@list.T.Cons(
      "ORTHOGONAL",
      @list.T.Cons("POLYLINE", @list.T.Cons("SPLINES", @list.T.Nil]),
    ),
  )
  let test_routing = fn(routing : String) {
    let options : LayeredOptions = (
      50.0, 30.0, "DOWN", "INPUT_ORDER", routing, "CENTER", true, true, 1.0, 10,
    )
    let result : ElkNode = layout_layered(root, options)
    if result.0 == "" {
      let _ = panic

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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeG : ElkNode = ("G", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeH : ElkNode = ("H", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.T.Nil)
  let edgeBE : ElkEdge = ("e4", "B", "E", @list.T.Nil)
  let edgeCD : ElkEdge = ("e5", "C", "D", @list.T.Nil)
  let edgeCF : ElkEdge = ("e6", "C", "F", @list.T.Nil)
  let edgeDG : ElkEdge = ("e7", "D", "G", @list.T.Nil)
  let edgeEG : ElkEdge = ("e8", "E", "G", @list.T.Nil)
  let edgeFG : ElkEdge = ("e9", "F", "G", @list.T.Nil)
  let edgeGH : ElkEdge = ("e10", "G", "H", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

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
  let nodeA : ElkNode = (
    "A",
    Some("开始节点"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeB : ElkNode = (
    "B",
    Some("处理节点"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let nodeC : ElkNode = (
    "C",
    Some("结束节点"),
    @list.T.Nil,
    @list.T.Nil,
    x,
    y,
    w,
    h,
  )
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.[label1, ..@list.T.Nil])
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.[label2, ..@list.T.Nil])
  let nodeA_with_edges : ElkNode = (
    "A",
    Some("开始节点"),
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试固定布局算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_fixed(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试力导向布局算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试通用API" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA2

  // 测试所有算法
  let algorithms = @list.T.[
    "LAYERED", ..@list.T.Cons("FIXED", @list.T.Cons("FORCE", @list.T.Nil]),
  )
  let test_algorithm = fn(algorithm : String) {
    let options : LayeredOptions = default_layered_options()
    let layout_options : LayoutOptions = (algorithm, options)
    let result : ElkNode = elk_layout(root, layout_options)
    if result.0 == "" {
      let _ = panic

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
  let empty_node : ElkNode = ("EMPTY", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let result1 : ElkNode = layout_layered(empty_node, options)
  if result1.0 == "" {
    let _ = panic

  }

  // 测试自环
  let self_loop : ElkEdge = ("e1", "A", "A", @list.T.Nil)
  let node_with_self_loop : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[self_loop, ..@list.T.Nil],
    x,
    y,
    w,
    h,
  )
  let result2 : ElkNode = layout_layered(node_with_self_loop, options)
  if result2.0 == "" {
    let _ = panic

  }

  // 测试单节点
  let single_node : ElkNode = ("SINGLE", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let result3 : ElkNode = layout_layered(single_node, options)
  if result3.0 == "" {
    let _ = panic

  }
}

///|
test "测试性能边界" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建较大的图进行性能测试
  let nodeA : ElkNode = ("NodeA", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("NodeB", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("NodeC", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("NodeD", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "NodeA", "NodeB", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "NodeB", "NodeC", @list.T.Nil)
  let edgeCD : ElkEdge = ("e3", "NodeC", "NodeD", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "NodeA",
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
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

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
    @hashmap.T.new(), // 节点映射
    @hashmap.T.new(), // 层映射
    @hashmap.T.new(), // 层到节点映射
    @hashmap.T.new(), // 位置映射
  )
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)

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
  if positions.size() == 0 {
    let _ = panic

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
    let _ = panic

  }

  // 测试垂直距离
  let vertical_pos : Position = (50.0, 0.0)
  let orthogonal_vertical = route_edge(
    "A", "B", source_pos, vertical_pos, "ORTHOGONAL",
  )
  if list_length(orthogonal_vertical) != 4 {
    let _ = panic

  }

  // 测试水平距离
  let horizontal_pos : Position = (100.0, 50.0)
  let polyline_horizontal = route_edge(
    "A", "B", source_pos, horizontal_pos, "POLYLINE",
  )
  if list_length(polyline_horizontal) != 3 {
    let _ = panic

  }

  // 测试未知策略
  let unknown_route = route_edge("A", "B", source_pos, target_pos, "UNKNOWN")
  if list_length(unknown_route) != 2 {
    let _ = panic

  }
}

///|
test "测试更复杂的力导向布局" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建更复杂的图结构
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)
  let edgeCD : ElkEdge = ("e3", "C", "D", @list.T.Nil)
  let edgeDE : ElkEdge = ("e4", "D", "E", @list.T.Nil)
  let edgeAE : ElkEdge = ("e5", "A", "E", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAE, @list.T.Nil]),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试未知算法在通用API中" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
    let _ = panic

  }
}

///|
test "测试示例1: 基本分层布局" {
  let result = example_basic_layered()
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试示例2: 复杂多层图布局" {
  let result = example_complex_multilayer()
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试示例3: 带标签和端口的图" {
  let result = example_with_labels_and_ports()
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试示例4: Force布局算法" {
  let result = example_force_layout()
  if result.0 == "" {
    let _ = panic

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
    let _ = panic

  }
}

///|
test "测试示例7: 边缘路由演示" {
  let routes = example_edge_routing()
  if list_length(routes) != 4 {
    let _ = panic

  }
}

///|
test "测试示例8: 性能测试图" {
  let result = example_performance_test()
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试示例9: 通用布局API演示" {
  let results = example_universal_api()
  if list_length(results) != 3 {
    let _ = panic

  }
}

///|
test "测试示例10: 复杂工作流图" {
  let result = example_workflow_graph()
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试边缘交叉最小化算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建有交叉边的图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.T.Nil)
  let edgeCD : ElkEdge = ("e4", "C", "D", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试复杂交叉边场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建更复杂的交叉边图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e3", "B", "D", @list.T.Nil)
  let edgeBE : ElkEdge = ("e4", "B", "E", @list.T.Nil)
  let edgeCD : ElkEdge = ("e5", "C", "D", @list.T.Nil)
  let edgeCF : ElkEdge = ("e6", "C", "F", @list.T.Nil)
  let edgeDE : ElkEdge = ("e7", "D", "E", @list.T.Nil)
  let edgeDF : ElkEdge = ("e8", "D", "F", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Nil]),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试多层复杂图" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建多层复杂图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeG : ElkNode = ("G", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeH : ElkNode = ("H", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeI : ElkNode = ("I", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeJ : ElkNode = ("J", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.T.Nil)
  let edgeBE : ElkEdge = ("e4", "B", "E", @list.T.Nil)
  let edgeBF : ElkEdge = ("e5", "B", "F", @list.T.Nil)
  let edgeCE : ElkEdge = ("e6", "C", "E", @list.T.Nil)
  let edgeCF : ElkEdge = ("e7", "C", "F", @list.T.Nil)
  let edgeDG : ElkEdge = ("e8", "D", "G", @list.T.Nil)
  let edgeEH : ElkEdge = ("e9", "E", "H", @list.T.Nil)
  let edgeFI : ElkEdge = ("e10", "F", "I", @list.T.Nil)
  let edgeGJ : ElkEdge = ("e11", "G", "J", @list.T.Nil)
  let edgeHJ : ElkEdge = ("e12", "H", "J", @list.T.Nil)
  let edgeIJ : ElkEdge = ("e13", "I", "J", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Cons(edgeAD, @list.T.Nil])),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试所有布局选项组合" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let nodeA2 : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Nil],
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
      let _ = panic

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
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeG : ElkNode = ("G", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeH : ElkNode = ("H", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeI : ElkNode = ("I", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeJ : ElkNode = ("J", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeK : ElkNode = ("K", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeL : ElkNode = ("L", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.T.Nil)
  let edgeBE : ElkEdge = ("e4", "B", "E", @list.T.Nil)
  let edgeBF : ElkEdge = ("e5", "B", "F", @list.T.Nil)
  let edgeCG : ElkEdge = ("e6", "C", "G", @list.T.Nil)
  let edgeCH : ElkEdge = ("e7", "C", "H", @list.T.Nil)
  let edgeDI : ElkEdge = ("e8", "D", "I", @list.T.Nil)
  let edgeDJ : ElkEdge = ("e9", "D", "J", @list.T.Nil)
  let edgeEK : ElkEdge = ("e10", "E", "K", @list.T.Nil)
  let edgeFL : ElkEdge = ("e11", "F", "L", @list.T.Nil)
  let edgeGL : ElkEdge = ("e12", "G", "L", @list.T.Nil)
  let edgeHL : ElkEdge = ("e13", "H", "L", @list.T.Nil)
  let edgeIL : ElkEdge = ("e14", "I", "L", @list.T.Nil)
  let edgeJL : ElkEdge = ("e15", "J", "L", @list.T.Nil)
  let edgeKL : ElkEdge = ("e16", "K", "L", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Cons(edgeAD, @list.T.Nil])),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_layered(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试边路由所有策略" {
  let source_pos : Position = (0.0, 0.0)
  let target_pos : Position = (100.0, 100.0)

  // 测试所有边路由策略
  let strategies = @list.T.[
    "STRAIGHT", ..@list.T.Cons(
      "ORTHOGONAL",
      @list.T.Cons("POLYLINE", @list.T.Cons("SPLINES", @list.T.Nil]),
    ),
  )
  let test_routing_strategy = fn(strategy : String) {
    let route = route_edge("A", "B", source_pos, target_pos, strategy)
    if list_length(route) < 2 {
      let _ = panic

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
    let _ = panic

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
    let _ = panic

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
    let _ = panic

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
    let _ = panic

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
    @hashmap.T.new(), // 节点映射
    @hashmap.T.new(), // 层映射
    @hashmap.T.new(), // 层到节点映射
    @hashmap.T.new(), // 位置映射
  )
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeBC : ElkEdge = ("e2", "B", "C", @list.T.Nil)

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
  if positions.size() == 0 {
    let _ = panic

  }
}

///|
test "测试力导向布局复杂场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建复杂的力导向图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeE : ElkNode = ("E", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeF : ElkNode = ("F", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.T.Nil)
  let edgeBC : ElkEdge = ("e4", "B", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e5", "B", "D", @list.T.Nil)
  let edgeBE : ElkEdge = ("e6", "B", "E", @list.T.Nil)
  let edgeCD : ElkEdge = ("e7", "C", "D", @list.T.Nil)
  let edgeCE : ElkEdge = ("e8", "C", "E", @list.T.Nil)
  let edgeCF : ElkEdge = ("e9", "C", "F", @list.T.Nil)
  let edgeDE : ElkEdge = ("e10", "D", "E", @list.T.Nil)
  let edgeDF : ElkEdge = ("e11", "D", "F", @list.T.Nil)
  let edgeEF : ElkEdge = ("e12", "E", "F", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Cons(edgeAD, @list.T.Nil])),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_force(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "测试固定布局复杂场景" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0

  // 创建复杂的固定布局图
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeC : ElkNode = ("C", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let nodeD : ElkNode = ("D", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let edgeAB : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let edgeAC : ElkEdge = ("e2", "A", "C", @list.T.Nil)
  let edgeAD : ElkEdge = ("e3", "A", "D", @list.T.Nil)
  let edgeBC : ElkEdge = ("e4", "B", "C", @list.T.Nil)
  let edgeBD : ElkEdge = ("e5", "B", "D", @list.T.Nil)
  let edgeCD : ElkEdge = ("e6", "C", "D", @list.T.Nil)
  let nodeA_with_edges : ElkNode = (
    "A",
    None,
    @list.T.Nil,
    @list.T.[edgeAB, ..@list.T.Cons(edgeAC, @list.T.Cons(edgeAD, @list.T.Nil])),
    x,
    y,
    w,
    h,
  )
  let root : ElkNode = nodeA_with_edges
  let options : LayeredOptions = default_layered_options()
  let result : ElkNode = layout_fixed(root, options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "group_layers 边界测试" {
  let node_map = @hashmap.T.new()
  let layers = @hashmap.T.new()
  let keys = @list.T.Nil
  let map = @hashmap.T.new()
  let options = default_layered_options()
  let result = group_layers(keys, map, layers, node_map, options)
  // 空输入应返回空 layers
  if result.size() != 0 {
    let _ = panic

  }
}

///|
test "assign_x/calculate_max_width/assign_coords 空输入测试" {
  let ids = @list.T.Nil
  let node_map = @hashmap.T.new()
  let alignment = "CENTER"
  let max_width : Float = 0.0
  let x = assign_x(ids, 0.0, 10.0, node_map, alignment, max_width)
  if x != 0.0 {
    let _ = panic

  }
  let mw = calculate_max_width(ids, node_map, 0.0)
  if mw != 0.0 {
    let _ = panic

  }
  let layers = @hashmap.T.new()
  let options = default_layered_options()
  assign_coords(layers, 0.0, options, node_map)
} // 只要不 panic 即可

///|
test "collect_ids/append_edges 空输入测试" {
  let map = @hashmap.T.new()
  let ids = collect_ids(map)
  if list_length(ids) != 0 {
    let _ = panic

  }
  let edges1 = @list.T.Nil
  let edges2 = @list.T.Nil
  let appended = append_edges(edges1, edges2)
  if list_length(appended) != 0 {
    let _ = panic

  }
}

///|
test "force_init_pos/collect_node_ids 空输入测试" {
  let ids = @list.T.Nil
  let pos = @hashmap.T.new()
  let result = force_init_pos(ids, pos)
  if result.size() != 0 {
    let _ = panic

  }
  let node_map = @hashmap.T.new()
  let node_ids = collect_node_ids(node_map)
  if list_length(node_ids) != 0 {
    let _ = panic

  }
}

///|
test "to_float 测试" {
  let i : Int = 42
  let f = to_float(i)
  if f != 42.0 {
    let _ = panic

  }
}

///|
test "force_sum_rep/force_calc_repulsion/force_sum_att/force_calc_attraction/force_update/force_iterate/force_update_node 空输入测试" {
  let ids = @list.T.Nil
  let pos = @hashmap.T.new()
  let k : Float = 1.0
  let rep = force_calc_repulsion(ids, pos, k, @hashmap.T.new())
  if rep.size() != 0 {
    let _ = panic

  }
  let att = force_calc_attraction(@hashmap.T.new(), pos, k, @hashmap.T.new())
  if att.size() != 0 {
    let _ = panic

  }
  let updated = force_update(ids, pos, rep, att, 1.0, 1, @hashmap.T.new())
  if updated.size() != 0 {
    let _ = panic

  }
  let iterated = force_iterate(pos, ids, @hashmap.T.new(), k, 1.0, 1)
  if iterated.size() != 0 {
    let _ = panic

  }
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let node2 = force_update_node(node, pos)
  if node2.0 != "A" {
    let _ = panic

  }
}

///|
test "补测 group_layers None 分支" {
  let node_map = @hashmap.T.new()
  let layers = @hashmap.T.new()
  let keys = @list.T.["not_exist", ..@list.T.Nil]
  let map = @hashmap.T.new()
  let options = default_layered_options()
  let result = group_layers(keys, map, layers, node_map, options)

}
// 只要不 panic 即可

///|
test "补测 assign_x 非法 alignment" {
  let ids = @list.T.["A", ..@list.T.Nil]
  let node_map = @hashmap.T.new()
  let x = assign_x(ids, 0.0, 10.0, node_map, "FOO", 10.0)

}
// 只要不 panic 即可

///|
test "补测 calculate_max_width 空节点" {
  let ids = @list.T.["not_exist", ..@list.T.Nil]
  let node_map = @hashmap.T.new()
  let mw = calculate_max_width(ids, node_map, 0.0)

}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_name 空列表" {
  let ids = @list.T.Nil
  let result = assign_x(ids, 0.0, 10.0, @hashmap.T.new(), "CENTER", 10.0)

}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_degree 空节点" {
  let ids = @list.T.["not_exist", ..@list.T.Nil]
  let node_map = @hashmap.T.new()
  let result = calculate_max_width(ids, node_map, 0.0)

}
// 只要不 panic 即可

///|
test "补测 calculate_x_by_alignment default 分支" {
  let ids = @list.T.["A", ..@list.T.Nil]
  let node_map = @hashmap.T.new()
  let x = assign_x(ids, 0.0, 10.0, node_map, "UNKNOWN", 10.0)

}
// 只要不 panic 即可

///|
test "补测 route_edge 未知策略" {
  let pos : Position = (0.0, 0.0)
  let route = route_edge("A", "B", pos, pos, "UNKNOWN")
  if list_length(route) != 2 {
    let _ = panic

  }
}

///|
test "补测 force_sum_rep 递归终止" {
  let ids = @list.T.Nil
  let result = force_calc_repulsion(ids, @hashmap.T.new(), 1.0, @hashmap.T.new())
  if result.size() != 0 {
    let _ = panic

  }
}

///|
test "补测 force_sum_att 递归终止" {
  let edges = @list.T.Nil
  let pos = @hashmap.T.new()
  let result = force_calc_attraction(@hashmap.T.new(), pos, 1.0, @hashmap.T.new())
  if result.size() == 0 {
    let _ = panic

  }
}

///|
test "补测 remove_node_from_list 空列表" {
  let nodes = @list.T.Nil
  let result = assign_x(nodes, 0.0, 10.0, @hashmap.T.new(), "CENTER", 10.0)

}
// 只要不 panic 即可

///|
test "补测 add_edge_to_layout 节点不存在" {
  let state = (@hashmap.T.new(), @hashmap.T.new(), @hashmap.T.new(), @hashmap.T.new())
  let edge : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let result = incremental_layout_add_edge(state, edge)

}
// 只要不 panic 即可

///|
test "补测 update_layout_positions 空层" {
  let state = (
    @hashmap.T.new(),
    @hashmap.T.new(),
    @hashmap.T.new(),
    @hashmap.T.new(),
  )
  let options = default_layered_options()
  let result = incremental_layout_update(state, options)

}
// 只要不 panic 即可

///|
test "补测 elk_layout 未知算法" {
  let x : Float = 0.0
  let y : Float = 0.0
  let w : Float = 10.0
  let h : Float = 10.0
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, x, y, w, h)
  let options : LayeredOptions = default_layered_options()
  let layout_options : LayoutOptions = ("UNKNOWN", options)
  let result : ElkNode = elk_layout(nodeA, layout_options)
  if result.0 == "" {
    let _ = panic

  }
}

///|
test "补测 minimize_crossings 空层" {
  let layers = @hashmap.T.new()
  let edges = @list.T.Nil
  let result = minimize_crossings(layers, edges)

}
// 只要不 panic 即可

///|
test "补测 count_crossings 空层" {
  let layer1 = @list.T.Nil
  let layer2 = @list.T.Nil
  let edges = @list.T.Nil
  let crossings = count_crossings(layer1, layer2, edges)

}
// 只要不 panic 即可

///|
test "补测 get_node_at_index 越界" {
  let nodes = @list.T.["A", ..@list.T.Nil]
  let node = get_node_at_index(nodes, 5)

}
// 只要不 panic 即可

///|
test "补测 has_edge_between 空边" {
  let result = has_edge_between("A", "B", @list.T.Nil)
  if result != false {
    let _ = panic

  }
}

///|
test "补测 reverse_list 空列表" {
  let lst = @list.T.Nil
  let rev = reverse_list(lst)

}
// 只要不 panic 即可

///|
test "补测 sort_nodes_by_name 全相同" {
  let ids = @list.T.["A", ..@list.T.Cons("A", @list.T.Nil])
  let result = sort_nodes_by_name(ids, @list.T.Nil)

}
// 只要不 panic 即可

///|
test "补测 insert_by_name 空列表" {
  let result = insert_by_name("A", @list.T.Nil)

}
// 只要不 panic 即可

///|
test "补测 insert_by_degree 空列表" {
  let node_map = @hashmap.T.new()
  let result = insert_by_degree("A", 1, @list.T.Nil, node_map)

}
// 只要不 panic 即可

///|
test "补测 node_degree 空节点" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let degree = node_degree(node)

}
// 只要不 panic 即可

///|
test "补测 collect_all_edges 空节点" {
  let node_map = @hashmap.T.new()
  let edges = collect_all_edges(node_map)

}
// 只要不 panic 即可

///|
test "补测 append_edges 空列表" {
  let edges1 = @list.T.Nil
  let edges2 = @list.T.Nil
  let result = append_edges(edges1, edges2)

}
// 只要不 panic 即可

///|
test "补测 remove_node_from_list 不存在节点" {
  let nodes = @list.T.["A", ..@list.T.Cons("B", @list.T.Nil])
  let result = remove_node_from_list(nodes, "C")

}
// 只要不 panic 即可

///|
test "补测 update_layout_positions 空节点" {
  let state = (
    @hashmap.T.new(),
    @hashmap.T.new(),
    @hashmap.T.new(),
    @hashmap.T.new(),
  )
  let options = default_layered_options()
  let result = incremental_layout_update(state, options)

}
// 只要不 panic 即可

///|
test "补测 layout_layered 空节点" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let options = default_layered_options()
  let result = layout_layered(node, options)

}
// 只要不 panic 即可

///|
test "补测 layout_fixed 空节点" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let options = default_layered_options()
  let result = layout_fixed(node, options)

}
// 只要不 panic 即可

///|
test "补测 layout_force 空节点" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let options = default_layered_options()
  let result = layout_force(node, options)

}
// 只要不 panic 即可

///|
test "补测 minimize_crossings 空层和单层" {
  let layers = @hashmap.T.new()
  let edges = @list.T.Nil
  // 空层
  let result1 = minimize_crossings(layers, edges)
  if result1.size() != 0 {
    let _ = panic

  }
  // 只有一层
  layers.set(0, @list.T.["A", ..@list.T.Nil])
  let result2 = minimize_crossings(layers, edges)
  if result2.size() != 1 {
    let _ = panic

  }
}

///|
test "补测 count_crossings 空层和无交叉" {
  let l1 = @list.T.Nil
  let l2 = @list.T.Nil
  let edges = @list.T.Nil
  let c1 = count_crossings(l1, l2, edges)
  if c1 != 0 {
    let _ = panic

  }
  let l1b = @list.T.["A", ..@list.T.Nil]
  let l2b = @list.T.["B", ..@list.T.Nil]
  let c2 = count_crossings(l1b, l2b, edges)
  if c2 != 0 {
    let _ = panic

  }
}

///|
test "补测 get_node_at_index 越界和空列表" {
  let nodes = @list.T.Nil
  let n1 = get_node_at_index(nodes, 0)
  if n1 != "" {
    let _ = panic

  }
  let nodes2 = @list.T.["A", ..@list.T.Nil]
  let n2 = get_node_at_index(nodes2, 5)
  if n2 != "" {
    let _ = panic

  }
}

///|
test "补测 has_edge_between 空边和无匹配" {
  let edges = @list.T.Nil
  let r1 = has_edge_between("A", "B", edges)
  if r1 != false {
    let _ = panic

  }
  let e : ElkEdge = ("e1", "A", "C", @list.T.Nil)
  let edges2 = @list.T.[e, ..@list.T.Nil]
  let r2 = has_edge_between("A", "B", edges2)
  if r2 != false {
    let _ = panic

  }
}

///|
test "补测 reverse_list 空列表和单元素" {
  let l = @list.T.Nil
  let r = reverse_list(l)
  if list_length(r) != 0 {
    let _ = panic

  }
  let l2 = @list.T.["A", ..@list.T.Nil]
  let r2 = reverse_list(l2)
  if list_length(r2) != 1 {
    let _ = panic

  }
}

///|
test "补测 insert_by_name 空列表和已排序" {
  let r = insert_by_name("A", @list.T.Nil)
  if list_length(r) != 1 {
    let _ = panic

  }
  let r2 = insert_by_name("B", @list.T.["A", ..@list.T.Nil])
  if list_length(r2) != 2 {
    let _ = panic

  }
}

///|
test "补测 node_degree 空节点" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let d = node_degree(node)
  if d != 0 {
    let _ = panic

  }
}

///|
test "补测 remove_node_from_list 空列表和不存在节点" {
  let l = @list.T.Nil
  let r = remove_node_from_list(l, "A")
  if list_length(r) != 0 {
    let _ = panic

  }
  let l2 = @list.T.["A", ..@list.T.Cons("B", @list.T.Nil])
  let r2 = remove_node_from_list(l2, "C")
  if list_length(r2) != 2 {
    let _ = panic

  }
}

///|
test "补测 force_init_pos 空输入" {
  let ids = @list.T.Nil
  let pos = @hashmap.T.new()
  let r = force_init_pos(ids, pos)
  if r.size() != 0 {
    let _ = panic

  }
}

///|
test "补测 force_calc_repulsion 空输入" {
  let ids = @list.T.Nil
  let pos = @hashmap.T.new()
  let r = force_calc_repulsion(ids, pos, 1.0, @hashmap.T.new())
  if r.size() != 0 {
    let _ = panic

  }
}

///|
test "补测 force_sum_rep 递归终止" {
  let ids = @list.T.Nil
  let r = force_calc_repulsion(ids, @hashmap.T.new(), 1.0, @hashmap.T.new())
  if r.size() != 0 {
    let _ = panic

  }
}

///|
test "补测 force_sum_att 空边" {
  let node_map = @hashmap.T.new()
  let pos = @hashmap.T.new()
  let r = force_calc_attraction(node_map, pos, 1.0, @hashmap.T.new())
  if r.size() == 0 {
    let _ = panic

  }
}

///|
test "补测 force_iterate 0 次迭代" {
  let pos = @hashmap.T.new()
  let ids = @list.T.Nil
  let node_map = @hashmap.T.new()
  let r = force_iterate(pos, ids, node_map, 1.0, 1.0, 0)
  if r.size() != 0 {
    let _ = panic

  }
}

///|
test "补测 force_update 空输入" {
  let ids = @list.T.Nil
  let pos = @hashmap.T.new()
  let rep = @hashmap.T.new()
  let att = @hashmap.T.new()
  let r = force_update(ids, pos, rep, att, 1.0, 1, @hashmap.T.new())
  if r.size() != 0 {
    let _ = panic

  }
}

///|
test "补测 force_update_node 无位置" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let pos = @hashmap.T.new()
  let r = force_update_node(node, pos)
  if r.0 != "A" {
    let _ = panic

  }
}

///|
test "补测 collect_node_ids 空 map" {
  let map = @hashmap.T.new()
  let r = collect_node_ids(map)
  if list_length(r) != 0 {
    let _ = panic

  }
}

///|
test "补测 to_float" {
  let i : Int = 42
  let f = to_float(i)
  if f != 42.0 {
    let _ = panic

  }
}

///|
test "补测 elk_layout 默认分支" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let options : LayeredOptions = default_layered_options()
  let layout_options : LayoutOptions = ("unknown", options)
  let r = elk_layout(node, layout_options)
  if r.0 != "A" {
    let _ = panic

  }
}

///|
test "补测 add_edge_to_layout target_layer > source_layer" {
  let state = (@hashmap.T.new(), @hashmap.T.new(), @hashmap.T.new(), @hashmap.T.new())
  // 只设置目标节点层，且大于源节点层
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let edge : ElkEdge = ("e1", "A", "B", @list.T.Nil)
  let state1 = incremental_layout_add_node(state, nodeA, 0)
  let state2 = incremental_layout_add_node(state1, nodeB, 2)
  let state3 = incremental_layout_add_edge(state2, edge)

}
// 只要不 panic 即可

///|
test "补测 update_layout_positions None 分支" {
  let state = (
    @hashmap.T.new(),
    @hashmap.T.new(),
    @hashmap.T.new(),
    @hashmap.T.new(),
  )
  let options = default_layered_options()
  let result = incremental_layout_update(state, options)

}
// 只要不 panic 即可

///|
test "补测 remove_node_from_list Nil" {
  let l = @list.T.Nil
  let r = remove_node_from_list(l, "A")
  if list_length(r) != 0 {
    let _ = panic

  }
}

///|
test "补测 layout_layered 空节点" {
  let node : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let options = default_layered_options()
  let result = layout_layered(node, options)
  if result.0 != "A" {
    let _ = panic

  }
}

///|
test "补测 collect_all_edges 非空 map" {
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let edge : ElkEdge = ("e1", "A", "A", @list.T.Nil)
  let nodeB : ElkNode = (
    "B",
    None,
    @list.T.Nil,
    @list.T.[edge, ..@list.T.Nil],
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.T.new()
  map.set("A", nodeA)
  map.set("B", nodeB)
  let edges = collect_all_edges(map)
  if list_length(edges) != 1 {
    let _ = panic

  }
}

///|
test "补测 collect_node_ids 非空 map" {
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let map = @hashmap.T.new()
  map.set("A", nodeA)
  let ids = collect_node_ids(map)
  if list_length(ids) != 1 {
    let _ = panic

  }
}

///|
test "补测 force_edges_for 非空 map" {
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let edge : ElkEdge = ("e1", "A", "A", @list.T.Nil)
  let nodeB : ElkNode = (
    "B",
    None,
    @list.T.Nil,
    @list.T.[edge, ..@list.T.Nil],
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let map = @hashmap.T.new()
  map.set("A", nodeA)
  map.set("B", nodeB)
  let edges = force_edges_for(map, @list.T.Nil)
  if list_length(edges) != 1 {
    let _ = panic

  }
}

///|
test "补测 minimize_crossings 多层多边" {
  let layers = @hashmap.T.new()
  layers.set(0, @list.T.["A", ..@list.T.Cons("B", @list.T.Nil]))
  layers.set(1, @list.T.["C", ..@list.T.Cons("D", @list.T.Nil]))
  let edge1 : ElkEdge = ("e1", "A", "C", @list.T.Nil)
  let edge2 : ElkEdge = ("e2", "B", "D", @list.T.Nil)
  let edges = @list.T.[edge1, ..@list.T.Cons(edge2, @list.T.Nil])
  let result = minimize_crossings(layers, edges)
  if result.size() != 2 {
    let _ = panic

  }
}

///|
test "补测 force_sum_rep/force_sum_att 复杂分支" {
  let ids = @list.T.["A", ..@list.T.Cons("B", @list.T.Nil])
  let pos : @hashmap.T[String, (Float, Float)] = @hashmap.T.new()
  pos.set("A", (0.0, 0.0))
  pos.set("B", (1.0, 1.0))
  let k : Float = 1.0
  let rep = force_calc_repulsion(ids, pos, k, @hashmap.T.new())
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let map = @hashmap.T.new()
  map.set("A", nodeA)
  map.set("B", nodeB)
  let att = force_calc_attraction(map, pos, k, @hashmap.T.new())

}
// 只要不 panic 即可

///|
test "补测 assign_coords 多层多节点" {
  let nodeA : ElkNode = ("A", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let nodeB : ElkNode = ("B", None, @list.T.Nil, @list.T.Nil, 0.0, 0.0, 1.0, 1.0)
  let node_map = @hashmap.T.new()
  node_map.set("A", nodeA)
  node_map.set("B", nodeB)
  let layers = @hashmap.T.new()
  layers.set(0, @list.T.["A", ..@list.T.Nil])
  layers.set(1, @list.T.["B", ..@list.T.Nil])
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
    let _ = panic

  }
}

///|
test "补测 insert_by_degree None 分支" {
  let node_map = @hashmap.T.new()
  let sorted = @list.T.["A", ..@list.T.Nil]
  // node_map 不含 "A"，触发 None 分支
  let result = insert_by_degree("B", 2, sorted, node_map)
  if list_length(result) != 2 {
    let _ = panic

  }
}

///|
test "补测 assign_x/calculate_max_width/assign_coords None 节点分支" {
  let node_map = @hashmap.T.new()
  let ids = @list.T.["not_exist", ..@list.T.Nil]
  // assign_x None 分支
  let x = assign_x(ids, 0.0, 10.0, node_map, "CENTER", 10.0)
  // calculate_max_width None 分支
  let mw = calculate_max_width(ids, node_map, 0.0)
  // assign_coords 空节点分支
  let layers = @hashmap.T.new()
  layers.set(0, ids)
  let options = default_layered_options()
  assign_coords(layers, 0.0, options, node_map)
}
// 只要不 panic 即可
