view: repeat_purchase_facts {
  derived_table: {
    sql: SELECT
        order_items.order_id
        , COUNT(DISTINCT repeat_order_items.id) AS number_subsequent_orders
        , MIN(repeat_order_items.created_at) AS next_order_date
        , MIN(repeat_order_items.order_id) AS next_order_id
      FROM order_items
      LEFT JOIN order_items repeat_order_items
        ON order_items.user_id = repeat_order_items.user_id
        AND order_items.created_at < repeat_order_items.created_at
      GROUP BY 1
       ;;
#     indexes: ["order_id"]
#     distribution: "order_id"
    persist_for: "24 hours"
  }

  dimension: order_id {
    type: number
    hidden: yes
    primary_key: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: next_order_id {
    type: number
    hidden: yes
    sql: ${TABLE}.next_order_id ;;
  }

  dimension: has_subsequent_order {
    label: "次オーダ有フラグ"
    type: yesno
    sql: ${next_order_id} > 0 ;;
  }

  dimension: number_subsequent_orders {
    label: "以降オーダー数"
    type: number
    sql: ${TABLE}.number_subsequent_orders ;;
  }

  dimension_group: next_order {
    label: "次オーダー"
    type: time
    timeframes: [raw, date]
    hidden: yes
    sql: ${TABLE}.next_order_date ;;
  }
}