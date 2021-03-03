view: customer_fact {
  derived_table: {
      sql:
        SELECT
          users.id  AS user_id,
          products.brand AS brand,
          COALESCE(SUM(order_items.sale_price ), 0) AS lifetime_spent,
          COUNT(DISTINCT order_items.id ) AS lifetime_purchase,
        FROM order_items  AS order_items
        FULL OUTER JOIN inventory_items  AS inventory_items ON inventory_items.id = order_items.inventory_item_id
        LEFT JOIN users  AS users ON order_items.user_id = users.id
        LEFT JOIN products  AS products ON products.id = inventory_items.product_id
        WHERE {% condition brand_selector %} products.brand {% endcondition %}
        GROUP BY 1,2 ;;
  }

  filter: brand_selector {
    label: "ブランド指定"
    type: string
    suggest_dimension: brand
  }

  dimension: user_id {label: "ユーザーID"}
  dimension: brand {label: "ブランド"}
  dimension: lifetime_spend {type: number label: "ライフタイムスペンド"}
  dimension: lifetime_purchase {type: number label: "ライフタイム購入数"}

  measure: average_lifetime_spend {
    label: "平均ライフタイムスペンド"
    type: average
    sql: ${lifetime_spend} ;;
    value_format_name: usd
  }
}
