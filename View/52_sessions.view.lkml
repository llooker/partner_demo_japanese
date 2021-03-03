view: sessions {
  derived_table: {
#     indexes: ["session_id"]
#     distribution: "session_id"
#     persist_for: "24 hours"
    sql: SELECT
        session_id
        , MIN(created_at) AS session_start
        , MAX(created_at) AS session_end
        , COUNT(*) AS number_of_events_in_session
        , SUM(CASE WHEN event_type IN ('Category','Brand') THEN 1 END) AS browse_events
        , SUM(CASE WHEN event_type = 'Product' THEN 1 END) AS product_events
        , SUM(CASE WHEN event_type = 'Cart' THEN 1 END) AS cart_events
        , SUM(CASE WHEN event_type = 'Purchase' THEN 1 end) AS purchase_events
        , MAX(user_id) AS session_user_id
        , MIN(id) AS landing_event_id
        , MAX(id) AS bounce_event_id
      FROM events
      GROUP BY session_id
       ;;
  }

  #####  Basic Web Info  ########

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: session_id {
    label: "セッションID"
    type: string
    primary_key: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: session_user_id {
    label: "セッションユーザーID"
    sql: ${TABLE}.session_user_id ;;
  }

  dimension: landing_event_id {
    label: "ランディングイベントID"
    sql: ${TABLE}.landing_event_id ;;
  }

  dimension: bounce_event_id {
    label: "バウンスイベントID"
    sql: ${TABLE}.bounce_event_id ;;
  }

  dimension_group: session_start {
    label: "セッション開始"
    type: time
#     timeframes: [time, date, week, month, hour_of_day, day_of_week]
    sql: ${TABLE}.session_start ;;
  }

  dimension_group: session_end {
    label: "セッション終了"
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.session_end ;;
  }

  dimension: duration {
    label: "セッション期間 (秒)"
    type: number
    sql: DATEDIFF('second', ${session_start_raw}, ${session_end_raw}) ;;
  }

  measure: average_duration {
    label: "平均セッション期間 (秒)"
    type: average
    value_format_name: decimal_2
    sql: ${duration} ;;
  }

  dimension: duration_seconds_tier {
    label: "セッション期間層 (秒)"
    type: tier
    tiers: [10, 30, 60, 120, 300]
    style: integer
    sql: ${duration} ;;
  }

  #####  Bounce Information  ########

  dimension: is_bounce_session {
    label: "バウンスセッションフラグ"
    type: yesno
    sql: ${number_of_events_in_session} = 1 ;;
  }

  measure: count_bounce_sessions {
    label: "バウンスセッション数"
    type: count

    filters: {
      field: is_bounce_session
      value: "Yes"
    }

    drill_fields: [detail*]
  }

  measure: percent_bounce_sessions {
    label: "直帰率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_bounce_sessions} / nullif(${count},0) ;;
  }

  ####### Session by event types included  ########

  dimension: number_of_browse_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.browse_events ;;
  }

  dimension: number_of_product_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.product_events ;;
  }

  dimension: number_of_cart_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.cart_events ;;
  }

  dimension: number_of_purchase_events_in_session {
    type: number
    hidden: yes
    sql: ${TABLE}.purchase_events ;;
  }

  dimension: includes_browse {
    label: "有ブラウズフラグ"
    type: yesno
    sql: ${number_of_browse_events_in_session} > 0 ;;
  }

  dimension: includes_product {
    label: "有プロダクト閲覧フラグ"
    type: yesno
    sql: ${number_of_product_events_in_session} > 0 ;;
  }

  dimension: includes_cart {
    label: "有カート閲覧フラグ"
    type: yesno
    sql: ${number_of_cart_events_in_session} > 0 ;;
  }

  dimension: includes_purchase {
    label: "有購入フラグ"
    type: yesno
    sql: ${number_of_purchase_events_in_session} > 0 ;;
  }

  measure: count_with_cart {
    label: "カートセッション数"
    type: count

    filters: {
      field: includes_cart
      value: "Yes"
    }

    drill_fields: [detail*]
  }

  measure: count_with_purchase {
    label: "購入セッション数"
    type: count

    filters: {
      field: includes_purchase
      value: "Yes"
    }

    drill_fields: [detail*]
  }

  dimension: number_of_events_in_session {
    label: "セッションイベント数"
    type: number
    sql: ${TABLE}.number_of_events_in_session ;;
  }

  ####### Linear Funnel   ########

  dimension: furthest_funnel_step {
    label: "最終ファネル段階"
    sql: CASE
      WHEN ${number_of_purchase_events_in_session} > 0 THEN '(5) Purchase'
      WHEN ${number_of_cart_events_in_session} > 0 THEN '(4) Add to Cart'
      WHEN ${number_of_product_events_in_session} > 0 THEN '(3) View Product'
      WHEN ${number_of_browse_events_in_session} > 0 THEN '(2) Browse'
      ELSE '(1) Land'
      END
       ;;
  }

  measure: all_sessions {
    view_label: "ファネル"
    label: "(1) 全セッション"
    type: count
    drill_fields: [detail*]
  }

  measure: count_browse_or_later {
    view_label: "ファネル"
    label: "(2) ブラウズ以上"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(2) Browse,(3) View Product,(4) Add to Cart,(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: count_product_or_later {
    view_label: "ファネル"
    label: "(3) プロダクト閲覧以上"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(3) View Product,(4) Add to Cart,(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: count_cart_or_later {
    view_label: "ファネル"
    label: "(4) カート以上"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(4) Add to Cart,(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: count_purchase {
    view_label: "ファネル"
    label: "(5) 購入"
    type: count

    filters: {
      field: furthest_funnel_step
      value: "(5) Purchase
      "
    }

    drill_fields: [detail*]
  }

  measure: cart_to_checkout_conversion {
    view_label: "ファネル"
    label: "カート=>チェックアウトコンバージョン"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_purchase} / nullif(${count_cart_or_later},0) ;;
  }

  measure: overall_conversion {
    view_label: "ファネル"
    label: "購入率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${count_purchase} / nullif(${count},0) ;;
  }

  set: detail {
    fields: [session_id, session_start_time, session_end_time, number_of_events_in_session, duration, number_of_purchase_events_in_session, number_of_cart_events_in_session]
  }
}
