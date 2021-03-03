view: order_items_share_of_wallet {
  view_label: "Share of Wallet"
  #
  #   - measure: total_sale_price
  #     type: sum
  #     value_format: '$#,###'
  #     sql: ${sale_price}
  #


  ########## Comparison for Share of Wallet ##########

  filter: item_name {
    view_label: "顧客内シェア（アイテム）"
    suggest_dimension: products.item_name
    suggest_explore: orders_with_share_of_wallet_application
  }

  filter: brand {
    view_label: "顧客内シェア（ブランド）"
    suggest_dimension: products.brand
    suggest_explore: orders_with_share_of_wallet_application
  }

  dimension: primary_key {
    sql: ${order_items.id} ;;
    primary_key: yes
    hidden: yes
  }

  dimension: item_comparison {
    view_label: "顧客内シェア（アイテム）"
    description: "指定アイテム対他アイテム対他ブランドの比較"
    sql: CASE
      WHEN {% condition item_name %} trim(products.item_name) {% endcondition %}
      THEN '(1) '||${products.item_name}
      WHEN  {% condition brand %} trim(products.brand) {% endcondition %}
      THEN '(2) '||${products.brand}||'のその他アイテム'
      ELSE '(3) その他'
      END
       ;;
  }

  dimension: brand_comparison {
    view_label: "顧客内シェア（ブランド）"
    description: "Compare a selected brand vs. all other brands"
    sql: CASE
      WHEN  {% condition brand %} trim(products.brand) {% endcondition %}
      THEN '(1) '||${products.brand}
      ELSE '(2) Rest of Population'
      END
       ;;
  }

  measure: total_sale_price_this_item {
    view_label: "顧客内シェア（アイテム）"
    type: sum
    hidden: yes
    sql: ${order_items.sale_price} ;;
    value_format_name: usd

    filters: {
      field: order_items_share_of_wallet.item_comparison
      value: "(1)%"
    }
  }

  measure: total_sale_price_this_brand {
    view_label: "顧客内シェア（ブランド）"
    type: sum
    hidden: yes
    value_format_name: usd
    sql: ${order_items.sale_price} ;;

    filters: {
      field: order_items_share_of_wallet.item_comparison
      value: "(2)%,(1)%"
    }
  }

  measure: total_sale_price_brand_v2 {
    view_label: "顧客内シェア（ブランド）"
    label: "総売上 - 指定ブランド"
    type: sum
    value_format_name: usd
    sql: ${order_items.sale_price} ;;

    filters: {
      field: order_items_share_of_wallet.brand_comparison
      value: "(1)%"
    }
  }

  measure: item_share_of_wallet_within_brand {
    view_label: "顧客内シェア（アイテム）"
    type: number
    description: "指定アイテム売り上げ割る同ブランドの他アイテム売り上げ。"
    #     view_label: 'Share of Wallet'
    value_format_name: percent_2
    sql: ${total_sale_price_this_item}*1.0 / nullif(${total_sale_price_this_brand},0) ;;
  }

  measure: item_share_of_wallet_within_company {
    view_label: "顧客内シェア（アイテム）"
    description: "指定アイテムのサイト上売上。"
    value_format_name: percent_2
    #     view_label: 'Share of Wallet'
    type: number
    sql: ${total_sale_price_this_item}*1.0 / nullif(${order_items.total_sale_price},0) ;;
  }

  measure: brand_share_of_wallet_within_company {
    view_label: "顧客内シェア（ブランド）"
    description: "指定ブランド売り上げを全ブランド売り上げで割った数値。"
    value_format_name: percent_2
    #     view_label: 'Share of Wallet'
    type: number
    sql: ${total_sale_price_brand_v2}*1.0 / nullif(${order_items.total_sale_price},0) ;;
  }
}
