- dashboard: 'inventory_coverage_dashboard'
  preferred_viewer: dashboards-next
  title: 在庫カバレッジダッシュボード
  layout: newspaper
  elements:
  - title: 出荷地別在庫カバレッジ比率
    name: 出荷地別在庫カバレッジ比率
    model: thelook_japanese
    explore: inventory_items
    type: looker_map
    fields:
    - inventory_items.stock_coverage_ratio
    - distribution_centers.location
    sorts:
    - inventory_items.stock_coverage_ratio desc
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    map_plot_mode: points
    heatmap_gridlines: false
    heatmap_opacity: 0.5
    show_region_field: true
    draw_map_labels_above_data: true
    map_tile_provider: positron
    map_position: fit_data
    map_scale_indicator: 'off'
    map_pannable: true
    map_zoomable: true
    map_marker_type: circle
    map_marker_icon_name: default
    map_marker_radius_mode: fixed
    map_marker_units: pixels
    map_marker_proportional_scale_type: linear
    map_marker_color_mode: value
    show_view_names: false
    show_legend: true
    quantize_map_value_colors: false
    custom_color_enabled: false
    custom_color: forestgreen
    show_single_value_title: true
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    map_value_colors:
    - red
    - green
    hidden_fields: []
    y_axes: []
    row: 0
    col: 0
    width: 12
    height: 8
  - title: 在庫カバレッジ比率
    name: 在庫カバレッジ比率
    model: thelook_japanese
    explore: inventory_items
    type: table
    fields:
    - inventory_items.stock_coverage_ratio
    - products.category
    - products.department
    pivots:
    - products.department
    sorts:
    - inventory_items.stock_coverage_ratio desc 0
    - products.department
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    limit_displayed_rows: false
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_scale_mode: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    series_types: {}
    hidden_fields: []
    y_axes: []
    note_state: collapsed
    note_display: below
    note_text: ''
    row: 0
    col: 12
    width: 12
    height: 8
  - title: 在庫カバレッジ分布
    name: 在庫カバレッジ分布
    model: thelook_japanese
    explore: inventory_items
    type: looker_area
    fields:
    - inventory_items.stock_coverage_ratio
    - products.department
    - products.brand
    - products.category
    filters:
      inventory_items.stock_coverage_ratio: NOT NULL
      order_items.count: ">100"
    sorts:
    - inventory_items.stock_coverage_ratio desc
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    stacking: ''
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    limit_displayed_rows: false
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: false
    x_axis_scale: auto
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    ordering: none
    show_null_labels: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: editable
    series_types: {}
    reference_lines:
    - reference_type: range
      line_value: mean
      range_start: min
      range_end: ".75"
      margin_top: deviation
      margin_value: mean
      margin_bottom: deviation
      label_position: right
      color: "#e62525"
      label: Understocked
    - reference_type: range
      line_value: mean
      range_start: ".75"
      range_end: '1.25'
      margin_top: deviation
      margin_value: mean
      margin_bottom: deviation
      label_position: center
      color: "#3cde4e"
      label: Standard
    - reference_type: range
      line_value: mean
      range_start: '1.25'
      range_end: max
      margin_top: deviation
      margin_value: mean
      margin_bottom: deviation
      label_position: left
      color: "#f8d039"
      label: Overstocked
    y_axis_max:
    - '3'
    hidden_fields: []
    y_axes: []
    row: 8
    col: 0
    width: 24
    height: 8
