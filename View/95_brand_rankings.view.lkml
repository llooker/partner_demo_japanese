view: brand_rankings {
  derived_table: {
    sql: SELECT
        TRIM(products.brand)  AS brand,
        COUNT(DISTINCT order_items.id ) AS item_count,
        RANK() OVER(ORDER BY COUNT(*) DESC) as rank
      FROM order_items  AS order_items
      FULL OUTER JOIN inventory_items  AS inventory_items ON inventory_items.id = order_items.inventory_item_id
      LEFT JOIN products  AS products ON products.id = inventory_items.product_id
      GROUP BY 1
       ;;
  }

  dimension: brand {
    label: "ブランド"
    primary_key: yes
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: items_count {
    label: "アイテム数"
    type: number
    sql: ${TABLE}.item_count ;;
  }

  dimension: rank_raw {
    label: "生ランク"
    type: number
    sql: ${TABLE}.rank ;;
  }

  parameter: max_rank {
    label: "ランク上限"
    type: number
  }

  dimension: rank {
    label: "ランク"
    type: string
    sql:
      CASE
        WHEN ${rank_raw} <= {% parameter max_rank %} THEN ${rank_raw}::VARCHAR
        ELSE 'Other'
      END ;;
  }

  dimension: rank_and_brand {
    label: "ブランドランク"
    type: string
    sql:
      CASE
        WHEN ${rank} = 'Other' THEN 'Other'
        ELSE ${rank} || '-' || ${brand}
      END ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [brand, items_count, rank_raw]
  }
}
