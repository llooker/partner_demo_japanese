- dashboard: 'brand_analytics_dashboard'
  preferred_viewer: dashboards-next
  title: ブランドアナリティクス
  layout: newspaper
  embed_style:
    background_color: "#f6f8fa"
    show_title: true
    title_color: "#3a4245"
    show_filters_bar: true
    tile_text_color: "#3a4245"
    text_tile_text_color: "#556d7a"
  elements:
  - title: オーダー数
    name: オーダー数
    model: thelook_japanese
    explore: order_items
    type: single_value
    fields:
    - order_items.order_count
    filters: {}
    sorts:
    - order_items.order_count desc
    limit: 500
    query_timezone: America/Los_Angeles
    font_size: medium
    text_color: black
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: products.brand
      期間: order_items.created_date
    row: 0
    col: 16
    width: 8
    height: 3
  - title: 購入者数
    name: 購入者数
    model: thelook_japanese
    explore: order_items
    type: single_value
    fields:
    - users.count
    filters: {}
    sorts:
    - users.count desc
    limit: 500
    query_timezone: America/Los_Angeles
    font_size: medium
    text_color: black
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: products.brand
      期間: order_items.created_date
    note_state: expanded
    note_display: above
    note_text: ''
    row: 0
    col: 0
    width: 8
    height: 3
  - title: 平均オーダー額
    name: 平均オーダー額
    model: thelook_japanese
    explore: order_items
    type: single_value
    fields:
    - order_items.average_sale_price
    filters: {}
    sorts:
    - order_items.average_sale_price desc
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    font_size: medium
    text_color: black
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: products.brand
      期間: order_items.created_date
    row: 0
    col: 8
    width: 8
    height: 3
  - title: トラフィックソース・OS別ブランド訪問
    name: トラフィックソース・OS別ブランド訪問
    model: thelook_japanese
    explore: events
    type: looker_donut_multiples
    fields:
    - users.traffic_source
    - events.os
    - events.count
    pivots:
    - users.traffic_source
    filters:
      users.traffic_source: "-NULL"
    sorts:
    - events.count desc 1
    - users.traffic_source
    limit: 20
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: true
    stacking: ''
    show_value_labels: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    show_null_labels: false
    font_size: 12
    colors:
    - "#64518A"
    - "#8D7FB9"
    - "#EA8A2F"
    - "#F2B431"
    - "#2DA5DE"
    - "#57BEBE"
    - "#7F7977"
    - "#B2A898"
    - "#494C52"
    series_labels:
      Display - events.count: ディスプレイ
      Email - events.count: メール
      Organic - events.count: オーガニック
      Search - events.count: サーチ
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: product_viewed.brand
      期間: events.event_date
    note_state: collapsed
    note_display: above
    note_text: ''
    row: 3
    col: 0
    width: 11
    height: 8
  - title: トッププロダクトカテゴリ - カート vs コンバージョン
    name: トッププロダクトカテゴリ - カート vs コンバージョン
    model: thelook_japanese
    explore: events
    type: looker_column
    fields:
    - product_viewed.category
    - sessions.overall_conversion
    - sessions.cart_to_checkout_conversion
    - sessions.count_cart_or_later
    filters:
      product_viewed.category: "-NULL"
    sorts:
    - sessions.count_cart_or_later desc
    limit: 8
    column_limit: 50
    query_timezone: America/Los_Angeles
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_combined: false
    y_axis_orientation:
    - right
    - left
    show_value_labels: true
    show_view_names: false
    colors:
    - "#64518A"
    - "#8D7FB9"
    stacking: ''
    x_axis_gridlines: false
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    x_axis_label_rotation: -45
    show_x_axis_ticks: true
    x_axis_scale: auto
    series_types:
      sessions.cart_to_checkout_conversion: line
      __FILE: thelook_event/web_analytics.dashboard.lookml
      __LINE_NUM: 632
      sessions.overall_conversion: line
    label_density: 25
    legend_position: center
    y_axis_labels:
    - Cart to Checkout Conversion Percent
    - Total Added to Cart
    show_null_labels: false
    label_rotation: 0
    ordering: none
    show_null_points: true
    point_style: circle_outline
    interpolation: linear
    hide_legend: false
    limit_displayed_rows: false
    y_axis_scale_mode: linear
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    y_axes:
    - label: Total Added to Cart
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: sessions.count_cart_or_later
        name: "(4) Add to Cart or later"
    - label: ''
      maxValue:
      minValue:
      orientation: right
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: sessions.overall_conversion
        name: Overall Conversion
      - id: sessions.cart_to_checkout_conversion
        name: Cart to Checkout Conversion
    series_labels:
      sessions.cart_to_checkout_conversion: カート=>購入率
      sessions.overall_conversion: 購入率
      sessions.count_cart_or_later: カート以上閲覧
    hidden_series: []
    hidden_fields: []
    listen:
      ブランド: product_viewed.brand
      期間: events.event_date
    row: 19
    col: 0
    width: 12
    height: 8
  - title: トップ訪問者・購入歴
    name: トップ訪問者・購入歴
    model: thelook_japanese
    explore: events
    type: table
    fields:
    - users.name
    - users.history
    - users.state
    - users.traffic_source
    - sessions.count
    filters:
      users.name: "-NULL"
    sorts:
    - sessions.count desc
    limit: 50
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: true
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: product_viewed.brand
      期間: events.event_date
    row: 37
    col: 0
    width: 12
    height: 10
  - title: 売上・価格トレンド
    name: 売上・価格トレンド
    model: thelook_japanese
    explore: order_items
    type: looker_line
    fields:
    - order_items.created_date
    - order_items.total_sale_price
    - order_items.average_sale_price
    filters: {}
    sorts:
    - order_items.total_sale_price desc
    limit: 500
    query_timezone: America/Los_Angeles
    stacking: ''
    x_axis_datetime: true
    y_axis_orientation:
    - left
    - right
    y_axis_combined: false
    y_axis_labels:
    - Total Sale Amount
    - Average Selling Price
    hide_points: true
    hide_legend: true
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: auto
    show_null_points: true
    point_style: none
    interpolation: linear
    colors:
    - "#F2B431"
    - "#57BEBE"
    x_axis_label: ''
    limit_displayed_rows: false
    y_axis_scale_mode: linear
    y_axes:
    - label: ''
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: order_items.total_sale_price
        name: 総売上
        axisId: order_items.total_sale_price
    - label: 平均価格
      maxValue:
      minValue:
      orientation: right
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: order_items.average_sale_price
        name: 平均売上
        axisId: order_items.average_sale_price
    hidden_fields: []
    listen:
      ブランド: products.brand
      期間: order_items.created_date
    note_state: collapsed
    note_display: hover
    note_text: ''
    row: 27
    col: 12
    width: 12
    height: 10
  - title: 部門・カテゴリ別売上
    name: 部門・カテゴリ別売上
    model: thelook_japanese
    explore: order_items
    type: table
    fields:
    - products.category
    - products.department
    - order_items.count
    - order_items.total_sale_price
    pivots:
    - products.department
    filters: {}
    sorts:
    - order_items.count desc 1
    - products.department
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: products.brand
      期間: order_items.created_date
    row: 37
    col: 12
    width: 12
    height: 10
  - title: トップブランド購入ユーザー
    name: トップブランド購入ユーザー
    model: thelook_japanese
    explore: order_items
    type: table
    fields:
    - users.name
    - users.email
    - users.history
    - order_items.count
    - order_items.total_sale_price
    filters: {}
    sorts:
    - order_items.count desc
    limit: 15
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: products.brand
      期間: order_items.created_date
    row: 19
    col: 12
    width: 12
    height: 8
  - title: "[ライフタイムオーダー数ピボット] 時間別セッション数"
    name: "[ライフタイムオーダー数ピボット] 時間別セッション数"
    model: thelook_japanese
    explore: events
    type: looker_column
    fields:
    - user_order_facts.lifetime_orders_tier
    - sessions.count
    - events.event_hour_of_day
    pivots:
    - user_order_facts.lifetime_orders_tier
    fill_fields:
    - events.event_hour_of_day
    filters: {}
    sorts:
    - user_order_facts.lifetime_orders_tier 0
    - events.event_hour_of_day
    limit: 500
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    stacking: normal
    show_value_labels: false
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: false
    show_x_axis_ticks: true
    x_axis_scale: auto
    label_density: 25
    legend_position: center
    y_axis_combined: true
    colors:
    - "#2DA5DE"
    - "#57BEBE"
    - "#EA8A2F"
    - "#F2B431"
    - "#64518A"
    - "#8D7FB9"
    - "#7F7977"
    - "#B2A898"
    - "#494C52"
    show_null_labels: false
    ordering: none
    show_null_points: true
    point_style: none
    interpolation: linear
    series_labels:
      '1': 1 Lifetime Purchase
      3 to 4 - 4 - sessions.count: 3-4
      5 to 9 - 5 - sessions.count: 5-9
      10 or Above - 6 - sessions.count: 10+
      1 - 2 - sessions.count: '1'
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    limit_displayed_rows: false
    y_axis_scale_mode: linear
    hidden_series:
    - Undefined
    hidden_fields: []
    y_axes: []
    listen:
      ブランド: product_viewed.brand
      期間: events.event_date
    note_state: collapsed
    note_display: hover
    note_text: this is a note about orders
    row: 3
    col: 11
    width: 13
    height: 8
  - title: ライフタイムブランド顧客内シェア
    name: ライフタイムブランド顧客内シェア
    model: thelook_japanese
    explore: orders_with_share_of_wallet_application
    type: looker_line
    fields:
    - order_items.months_since_signup
    - order_items_share_of_wallet.brand_share_of_wallet_within_company
    - order_items_share_of_wallet.total_sale_price_brand_v2
    filters:
      order_items.months_since_signup: "<=18"
    sorts:
    - order_items.months_since_signup
    limit: 12
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
    y_axis_combined: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    x_axis_scale: ordinal
    y_axis_scale_mode: linear
    show_null_points: true
    point_style: none
    interpolation: linear
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    totals_color: "#808080"
    show_row_numbers: true
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: gray
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    font_size: '12'
    value_labels: legend
    label_type: labPer
    colors:
    - "#F2B431"
    - "#8D7FB9"
    - "#7F7977"
    - "#B2A898"
    - "#494C52#64518A"
    y_axis_orientation:
    - left
    - right
    series_types: {}
    conditional_formatting_ignored_fields: []
    y_axes:
    - label: ブランド内構成率
      maxValue:
      minValue:
      orientation: left
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: order_items_share_of_wallet.brand_share_of_wallet_within_company
        name: ブランド内構成率
        axisId: order_items_share_of_wallet.brand_share_of_wallet_within_company
    - label:
      maxValue:
      minValue:
      orientation: right
      showLabels: true
      showValues: true
      tickDensity: default
      tickDensityCustom: 5
      type: linear
      unpinAxis: false
      valueFormat:
      series:
      - id: order_items_share_of_wallet.total_sale_price_brand_v2
        name: フィルタブランド売上
        axisId: order_items_share_of_wallet.total_sale_price_brand_v2
    hidden_series: []
    x_axis_label: ユーザー経過月数
    series_labels:
      order_items_share_of_wallet.total_sale_price_brand_v2: フィルタブランド売上
      order_items_share_of_wallet.brand_share_of_wallet_within_company: ブランド内構成率
    hidden_fields: []
    listen:
      ブランド: order_items_share_of_wallet.brand
    row: 11
    col: 0
    width: 12
    height: 8
  - title: 相関ブランド分析
    name: 相関ブランド分析
    model: thelook_japanese
    explore: affinity
    type: looker_line
    fields:
    - product_b.brand
    - affinity.avg_order_affinity
    - affinity.avg_user_affinity
    - affinity.combined_affinity
    filters:
      affinity.product_b_id: "-NULL"
      affinity.avg_order_affinity: NOT NULL
    sorts:
    - affinity.combined_affinity desc
    limit: 15
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
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
    ordering: none
    show_null_labels: false
    colors:
    - "#57BEBE"
    - "#EA8A2F"
    - "#F2B431"
    - "#64518A"
    - "#8D7FB9"
    - "#7F7977"
    - "#B2A898"
    - "#494C52"
    show_null_points: true
    point_style: circle_outline
    hidden_series:
    - product_a.count
    - product_b.count
    interpolation: linear
    hidden_fields:
    - affinity.combined_affinity
    series_labels:
      affinity.avg_order_affinity: 相関スコア（カートベース）
      affinity.avg_user_affinity: 相関スコア（ユーザーベース）
    y_axes: []
    listen:
      ブランド: product_a.brand
    row: 27
    col: 0
    width: 12
    height: 10
  - title: ブランド相関レポート
    name: ブランド相関レポート
    model: thelook_japanese
    explore: affinity
    type: table
    fields:
    - product_a.brand
    - product_b.brand
    - affinity.avg_order_affinity
    - affinity.avg_user_affinity
    - affinity.combined_affinity
    filters:
      affinity.product_b_id: "-NULL"
      affinity.avg_order_affinity: NOT NULL
    sorts:
    - affinity.combined_affinity desc
    limit: 15
    column_limit: 50
    query_timezone: America/Los_Angeles
    show_view_names: false
    show_row_numbers: true
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
    ordering: none
    show_null_labels: false
    hidden_fields:
    - affinity.combined_affinity
    truncate_column_names: false
    hide_totals: false
    hide_row_totals: false
    table_theme: gray
    limit_displayed_rows: false
    enable_conditional_formatting: false
    conditional_formatting_ignored_fields: []
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    series_labels:
      product_a.brand: フィルタブランド名
      product_b.brand: 相関ブランド名
      affinity.avg_order_affinity: 相関スコア（カートベース）
      affinity.avg_user_affinity: 相関スコア（ユーザーベース）
    y_axes: []
    listen:
      ブランド: product_a.brand
    row: 11
    col: 12
    width: 12
    height: 8
  filters:
  - name: ブランド
    title: ブランド
    type: field_filter
    default_value: Calvin Klein
    allow_multiple_values: true
    required: false
    model: thelook_japanese
    explore: order_items
    listens_to_filters: []
    field: products.brand
  - name: 期間
    title: 期間
    type: date_filter
    default_value: 90 days
    allow_multiple_values: true
    required: false
