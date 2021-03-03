view: affinity {
  derived_table: {
    persist_for: "24 hours"
#     distribution: "product_a_id"
#     indexes: ["product_a_id", "product_b_id"]
    sql: SELECT
        product_a_id
        , product_b_id
        , joint_user_freq
        , joint_order_freq
        , top1.prod_freq AS product_a_freq
        , top2.prod_freq AS product_b_freq

      FROM
          (
              SELECT
                up1.prod_id AS product_a_id
                , up2.prod_id AS product_b_id
                , COUNT(*) AS joint_user_freq
              FROM ${user_order_product.SQL_TABLE_NAME} AS up1
              LEFT JOIN ${user_order_product.SQL_TABLE_NAME} AS up2
                ON up1.user_id = up2.user_id
                AND up1.prod_id <> up2.prod_id
              GROUP BY product_a_id, product_b_id
          ) AS juf

      LEFT JOIN
          (
              SELECT
                op1.prod_id AS oproduct_a_id
                , op2.prod_id AS oproduct_b_id
                , COUNT(*) AS joint_order_freq
              FROM ${user_order_product.SQL_TABLE_NAME} op1
              LEFT JOIN ${user_order_product.SQL_TABLE_NAME} op2
                ON op1.order_id = op2.order_id
                AND op1.prod_id <> op2.prod_id
              GROUP BY oproduct_a_id, oproduct_b_id
          ) AS jof

        ON jof.oproduct_a_id = juf.product_a_id
        AND jof.oproduct_b_id = juf.product_b_id
      LEFT JOIN ${total_order_product.SQL_TABLE_NAME} top1
        ON top1.prod_id = juf.product_a_id
      LEFT JOIN ${total_order_product.SQL_TABLE_NAME} top2
        ON top2.prod_id = juf.product_b_id
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: product_a_id {
    label: "製品A ID"
    sql: ${TABLE}.product_a_id ;;
  }

  dimension: product_b_id {
    label: "製品B ID"
    sql: ${TABLE}.product_b_id ;;
  }

  dimension: joint_user_freq {
    label: "相関ユーザー数"
    description: "製品AとBを両方購入したことのあるユーザー数。"
    type: number
    sql: ${TABLE}.joint_user_freq ;;
  }

  dimension: joint_order_freq {
    label: "相関オーダー数"
    description: "製品AとBの両方が含まれているオーダー数。"
    type: number
    sql: ${TABLE}.joint_order_freq ;;
  }

  dimension: product_a_freq {
    label: "製品A購入回数"
    description: "製品Aが購入された回数。"
    type: number
    sql: ${TABLE}.product_a_freq ;;
  }

  dimension: product_b_freq {
    label: "製品B購入回数"
    description: "製品Bが購入された回数。"
    type: number
    sql: ${TABLE}.product_b_freq ;;
  }

  dimension: user_affinity {
    label: "ユーザー相関"
    hidden: yes
    type: number
    sql: 1.0*${joint_user_freq}/NULLIF((${product_a_freq}+${product_b_freq})-(${joint_user_freq}),0) ;;
    value_format_name: percent_2
  }

  dimension: order_affinity {
    label: "オーダー相関"
    hidden: yes
    type: number
    sql: 1.0*${joint_order_freq}/NULLIF((${product_a_freq}+${product_b_freq})-(${joint_order_freq}),0) ;;
    value_format_name: percent_2
  }

  measure: avg_user_affinity {
    label: "相関スコア（ユーザー購入歴ベース）"
    description: "両製品を購入したユーザー数を各製品のオーダー数によって割った数値。"
    type: average
    sql: 100.0 * ${user_affinity} ;;
    value_format_name: decimal_2
  }

  measure: avg_order_affinity {
    label: "相関スコア（オーダーバスケットベース）"
    description: "両製品を含むオーダーバスケットを各製品のオーダー数によって割った数値。"
    type: average
    sql: 100.0 * ${order_affinity} ;;
    value_format_name: decimal_2
  }

  measure: combined_affinity {
    label: "総相関"
    type: number
    sql: ${avg_user_affinity} + ${avg_order_affinity} ;;
  }

  set: detail {
    fields: [product_a_id,product_b_id,user_affinity,order_affinity]
  }
}



#############################################
#Table that aggregates the products purchased by user and order id
view: user_order_product {
  derived_table: {
    persist_for: "24 hours"
#     distribution: "prod_id"
#     sortkeys: ["prod_id", "user_id", "order_id"]
    sql: SELECT
        oi.user_id AS user_id
        , p.id AS prod_id
        , oi.order_id AS order_id
      FROM order_items oi
      LEFT JOIN inventory_items ii
        ON oi.inventory_item_id = ii.id
      LEFT JOIN products p
        ON ii.product_id = p.id
      GROUP BY 1,2,3
       ;;
  }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  dimension: user_id {
    label: "ユーザーID"
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: prod_id {
    label: "製品ID"
    type: number
    sql: ${TABLE}.prod_id ;;
  }

  dimension: order_id {
    label: "オーダーID"
    type: number
    sql: ${TABLE}.order_id ;;
  }
}

#################################################
#Table to count the total times a product id has been purchased
view: total_order_product {
  derived_table: {
    persist_for: "24 hours"
#     distribution: "prod_id"
#     sortkeys: ["prod_id"]
    sql: SELECT
        p.id AS prod_id
        , COUNT(*) AS prod_freq
      FROM order_items oi
      LEFT JOIN inventory_items
        ON oi.inventory_item_id = inventory_items.id
      LEFT JOIN products p
        ON inventory_items.product_id = p.id
      GROUP BY p.id
       ;;
  }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  dimension: prod_id {
    label: "製品ID"
    sql: ${TABLE}.prod_id ;;
  }

  dimension: prod_freq {
    label: "製品購入数"
    type: number
    sql: ${TABLE}.prod_freq ;;
  }
}