view: events {
  sql_table_name: events ;;

  dimension: event_id {
    label: "イベントID"
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: session_id {
    label: "セッションID"
    type: number
    hidden: yes
    sql: ${TABLE}.session_id ;;
  }

  dimension: ip {
    label: "IPアドレス"
    view_label: "ビジター"
    sql: ${TABLE}.ip_address ;;
  }

  dimension: user_id {
    label: "ユーザーID"
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: event {
    label: "イベント"
    type: time
#     timeframes: [time, date, hour, time_of_day, hour_of_day, week, day_of_week_index, day_of_week]
    sql: ${TABLE}.created_at ;;
  }

  dimension: sequence_number {
    label: "イベント順列"
    type: number
    description: "Within a given session, what order did the events take place in? 1=First, 2=Second, etc"
    sql: ${TABLE}.sequence_number ;;
  }

  dimension: is_entry_event {
    label: "エントリーイベントフラグ"
    type: yesno
    description: "Yes indicates this was the entry point / landing page of the session"
    sql: ${sequence_number} = 1 ;;
  }

  dimension: is_exit_event {
    type: yesno
    label: "UTMソース"
    sql: ${sequence_number} = ${sessions.number_of_events_in_session} ;;
    description: "Yes indicates this was the exit point / bounce page of the session"
  }

  measure: count_bounces {
    label: "バウンス数"
    type: count
    description: "Count of events where those events were the bounce page for the session"

    filters: {
      field: is_exit_event
      value: "Yes"
    }
  }

  measure: bounce_rate {
    label: "バウンス率"
    type: number
    value_format_name: percent_2
    description: "Percent of events where those events were the bounce page for the session, out of all events"
    sql: ${count_bounces}*1.0 / nullif(${count}*1.0,0) ;;
  }

  dimension: full_page_url {
    label: "ページURL"
    sql: ${TABLE}.uri ;;
  }

  dimension: viewed_product_id {
    label: "閲覧プロダクトID"
    type: number
    sql: CASE
        WHEN ${event_type} = 'Product' THEN right(${full_page_url},length(${full_page_url})-9)
      END
       ;;
  }

  dimension: event_type {
    label: "イベントタイプ"
    sql: ${TABLE}.event_type ;;
  }

  dimension: funnel_step {
    label: "ファネル段階"
    description: "Login -> Browse -> Add to Cart -> Checkout"
    sql: CASE
        WHEN ${event_type} IN ('Login', 'Home') THEN '(1) Land'
        WHEN ${event_type} IN ('Category', 'Brand') THEN '(2) Browse Inventory'
        WHEN ${event_type} = 'Product' THEN '(3) View Product'
        WHEN ${event_type} = 'Cart' THEN '(4) Add Item to Cart'
        WHEN ${event_type} = 'Purchase' THEN '(5) Purchase'
      END
       ;;
  }

  measure: unique_visitors {
    label: "ユニークビジター数"
    type: count_distinct
    description: "Uniqueness determined by IP Address and User Login"
    view_label: "ビジター"
    sql: ${ip} ;;
    drill_fields: [visitors*]
  }

  dimension: location {
    type: location
    label: "ロケーション"
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: approx_location {
    type: location
    label: "ロケーション略"
    view_label: "ビジター"
    sql_latitude: round(${TABLE}.latitude,1) ;;
    sql_longitude: round(${TABLE}.longitude,1) ;;
  }

  dimension: has_user_id {
    label: "有ユーザーIDフラグ"
    type: yesno
    view_label: "ビジター"
    description: "Did the visitor sign in as a website user?"
    sql: ${users.id} > 0 ;;
  }

  dimension: browser {
    label: "ブラウザ"
    view_label: "ビジター"
    sql: ${TABLE}.browser ;;
  }

  dimension: os {
    label: "オペレーティングシステム"
    view_label: "ビジター"
    sql: ${TABLE}.os ;;
  }

  measure: count {
    type: count
    drill_fields: [simple_page_info*]
  }

  measure: sessions_count {
    label: "セッション数"
    type: count_distinct
    sql: ${session_id} ;;
  }

  measure: count_m {
    label: "カウント(億単位)"
    type: number
    hidden: yes
    sql: ${count}/1000000.0 ;;
    drill_fields: [simple_page_info*]
    value_format: "#.### \"M\""
  }

  measure: unique_visitors_m {
    label: "ユニークビジター（億単位）"
    view_label: "ビジター"
    type: number
    sql: count (distinct ${ip}) / 1000000.0 ;;
    description: "Uniqueness determined by IP Address and User Login"
    value_format: "#.### \"M\""
    hidden: yes
    drill_fields: [visitors*]
  }

  measure: unique_visitors_k {
    label: "ユニークビジター（千単位)"
    view_label: "ビジター"
    type: number
    hidden: yes
    description: "Uniqueness determined by IP Address and User Login"
    sql: count (distinct ${ip}) / 1000.0 ;;
    value_format: "#.### \"k\""
    drill_fields: [visitors*]
  }

  set: simple_page_info {
    fields: [event_id, event_time, event_type,
      #       - os
      #       - browser
      full_page_url, user_id, funnel_step]
  }

  set: visitors {
    fields: [ip, os, browser, user_id, count]
  }
}
