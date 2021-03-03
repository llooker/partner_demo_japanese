view: user_order_facts {
  derived_table: {
    sql: SELECT
        user_id
        , COUNT(DISTINCT order_id) AS lifetime_orders
        , SUM(sale_price) AS lifetime_revenue
        , MIN(created_at) AS first_order
        , MAX(created_at) AS latest_order
        , COUNT(DISTINCT DATE_TRUNC('month', created_at)) AS number_of_distinct_months_with_orders
      FROM order_items
      GROUP BY user_id
       ;;
#     indexes: ["user_id"]
#     distribution: "user_id"
    persist_for: "24 hours"
  }

  dimension: user_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  ##### Time and Cohort Fields ######

  dimension_group: first_order {
    label: "初購入"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order ;;
  }

  dimension_group: latest_order {
    label: "最終購入"
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.latest_order ;;
  }

  dimension: days_as_customer {
    label: "顧客期間（日）"
    description: "初購入日から最終購入日までの日数。"
    type: number
    sql: DATEDIFF('day', ${TABLE}.first_order, ${TABLE}.latest_order)+1 ;;
  }

  dimension: days_as_customer_tiered {
    label: "顧客期間層（日）"
    type: tier
    tiers: [0, 1, 7, 14, 21, 28, 30, 60, 90, 120]
    sql: ${days_as_customer} ;;
    style: integer
  }

  ##### Lifetime Behavior - Order Counts ######

  dimension: lifetime_orders {
    label: "ライフタイムオーダー数"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: repeat_customer {
    label: "リピーターラベル"
    description: "ライフタイムオーダー数 > 1"
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  dimension: lifetime_orders_tier {
    label: "ライフタイムオーダー数層"
    type: tier
    tiers: [0, 1, 2, 3, 5, 10]
    sql: ${lifetime_orders} ;;
    style: integer
  }

  measure: average_lifetime_orders {
    label: "平均ライフタイムオーダー数"
    type: average
    value_format_name: decimal_2
    sql: ${lifetime_orders} ;;
  }

  dimension: distinct_months_with_orders {
    label: "有オーダー月数"
    type: number
    sql: ${TABLE}.number_of_distinct_months_with_orders ;;
  }

  ##### Lifetime Behavior - Revenue ######

  dimension: lifetime_revenue {
    label: "ライフタイムレベニュー"
    type: number
    value_format_name: usd
    sql: ${TABLE}.lifetime_revenue ;;
  }

  dimension: lifetime_revenue_tier {
    label: "ライフタイムレベニュー層"
    type: tier
    tiers: [0, 25, 50, 100, 200, 500, 1000]
    sql: ${lifetime_revenue} ;;
    style: integer
  }

  measure: average_lifetime_revenue {
    label: "平均ライフタイムレベニュー"
    type: average
    value_format_name: usd
    sql: ${lifetime_revenue} ;;
  }
}