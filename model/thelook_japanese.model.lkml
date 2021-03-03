connection: "snowlooker"
label: "ECサイトデータ"
include: "/**/*.view" # include all the views
include: "/**/*.dashboard" # include all the dashboards

datagroup: ecommerce_etl {
  sql_trigger: SELECT max(completed_at) FROM public.etl_jobs ;;
  max_cache_age: "24 hours"}
persist_with: ecommerce_etl
############ Base Explores #############

# FROM
explore: order_items {
  label: "(1) オーダー、アイテム、ユーザー関連"
  view_name: order_items
  view_label: "オーダー"
  always_filter: {
    filters: {
      field: created_date
      value: "last 90 days"
    }
  }

  join: order_facts {
    view_label: "オーダー"
    relationship: many_to_one
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  }

  join: inventory_items {
    view_label: "在庫アイテム"
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: users {
    view_label: "ユーザー"
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: user_order_facts {
    view_label: "ユーザー"
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

  join: products {
    view_label: "プロダクト"
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

  join: repeat_purchase_facts {
    view_label: "リピーター"
    relationship: many_to_one
    type: full_outer
    sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id} ;;
  }

  join: distribution_centers {
    view_label: "物流センター"
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }

  join: brand_rankings {
    view_label: "ブランドランキング"
    sql_on: ${products.brand} = ${brand_rankings.brand} ;;
    relationship: many_to_one
  }
}


#########  Event Data Explores #########

explore: events {
  label: "(2) ページイベントデータ関連"
  view_label: "イベント"

  join: sessions {
    view_label: "セッション"
    sql_on: ${events.session_id} =  ${sessions.session_id} ;;
    relationship: many_to_one
  }

  join: session_landing_page {
    view_label: "ランディングページ"
    from: events
    sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id} ;;
    fields: [simple_page_info*]
    relationship: one_to_one
  }

  join: session_bounce_page {
    view_label: "バウンスページ"
    from: events
    sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id} ;;
    fields: [simple_page_info*]
    relationship: many_to_one
  }

  join: product_viewed {
    view_label: "閲覧製品"
    from: products
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }

  join: users {
    view_label: "ユーザー"
    sql_on: ${sessions.session_user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: user_order_facts {
    view_label: "ユーザー"
    sql_on: ${users.id} = ${user_order_facts.user_id} ;;
    relationship: one_to_one
  }
}

explore: sessions {
  label: "(3) ウェブセッションデータ関連"
  view_label: "セッション"

  join: events {
    view_label: "イベント"
    sql_on: ${sessions.session_id} = ${events.session_id} ;;
    relationship: one_to_many
  }

  join: product_viewed {
    view_label: "閲覧製品"
    from: products
    sql_on: ${events.viewed_product_id} = ${product_viewed.id} ;;
    relationship: many_to_one
  }

  join: session_landing_page {
    view_label: "ランディングページ"
    from: events
    sql_on: ${sessions.landing_event_id} = ${session_landing_page.event_id} ;;
    fields: [session_landing_page.simple_page_info*]
    relationship: one_to_one
  }

  join: session_bounce_page {
    view_label: "バウンスページ"
    from: events
    sql_on: ${sessions.bounce_event_id} = ${session_bounce_page.event_id} ;;
    fields: [session_bounce_page.simple_page_info*]
    relationship: one_to_one
  }

  join: users {
    view_label: "ユーザー"
    relationship: many_to_one
    sql_on: ${users.id} = ${sessions.session_user_id} ;;
  }

  join: user_order_facts {
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${users.id} ;;
    view_label: "ユーザー"
  }
}


#########  Advanced Extensions #########

explore: affinity {
  label: "(4) バスケット解析"

  always_filter: {
    filters: {
      field: affinity.product_b_id
      value: "-NULL"
    }
  }

  join: product_a {
    from: products
    view_label: "製品A詳細データ"
    relationship: many_to_one
    sql_on: ${affinity.product_a_id} = ${product_a.id} ;;
  }

  join: product_b {
    from: products
    view_label: "製品B詳細データ"
    relationship: many_to_one
    sql_on: ${affinity.product_b_id} = ${product_b.id} ;;
  }
}

explore: orders_with_share_of_wallet_application {
  label: "(5) 顧客内シェア解析"
  extends: [order_items]
  view_name: order_items

  join: order_items_share_of_wallet {
    view_label: "顧客内シェア"
  }
}

explore: journey_mapping {
  label: "(6) カスタマージャーニーマップ"
  extends: [order_items]
  view_name: order_items

  join: repeat_purchase_facts {
    view_label: "リピート購入"
    relationship: many_to_one
    sql_on: ${repeat_purchase_facts.next_order_id} = ${order_items.order_id} ;;
    type: left_outer
  }

  join: next_order_items {
    view_label: "リピート購入"
    from: order_items
    sql_on: ${repeat_purchase_facts.next_order_id} = ${next_order_items.order_id} ;;
    relationship: many_to_many
  }

  join: next_order_inventory_items {
    view_label: "次オーダー在庫"
    from: inventory_items
    relationship: many_to_one
    sql_on: ${next_order_items.inventory_item_id} = ${next_order_inventory_items.id} ;;
  }

  join: next_order_products {
    view_label: "次オーダープロダクト"
    from: products
    relationship: many_to_one
    sql_on: ${next_order_inventory_items.product_id} = ${next_order_products.id} ;;
  }
}


explore: inventory_items{
  label: "(7) 在庫分析"
  fields: [ALL_FIELDS*,-order_items.median_sale_price]

  join: order_facts {
    view_label: "オーダー"
    relationship: many_to_one
    sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  }

  join: order_items {
    view_label: "商品"
    #Left Join only brings in items that have been sold as order_item
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }

  join: users {
    view_label: "ユーザー"
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: user_order_facts {
    view_label: "ユーザー"
    relationship: many_to_one
    sql_on: ${user_order_facts.user_id} = ${order_items.user_id} ;;
  }

  join: products {
    view_label: "プロダクト"
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

  join: repeat_purchase_facts {
    view_label: "リピート購入"
    relationship: many_to_one
    type: full_outer
    sql_on: ${order_items.order_id} = ${repeat_purchase_facts.order_id} ;;
  }

  join: distribution_centers {
    view_label: "物流センター"
    type: left_outer
    sql_on: ${distribution_centers.id} = ${inventory_items.product_distribution_center_id} ;;
    relationship: many_to_one
  }
}

explore: inventory_snapshot {
  label: "(8) 在庫スナップショット分析"
  join: trailing_sales_snapshot {
    sql_on: ${inventory_snapshot.product_id}=${trailing_sales_snapshot.product_id}
    AND ${inventory_snapshot.snapshot_date}=${trailing_sales_snapshot.snapshot_date};;
    type: left_outer
    relationship: one_to_one
  }

  join: products {
    view_label: "プロダクト"
    sql_on: ${inventory_snapshot.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    view_label: "物流センター"
    sql_on: ${products.distribution_center_id}=${distribution_centers.id} ;;
    relationship: many_to_one
  }
}


















explore: kitten_order_items {
  label: "Order Items (Kittens)"
  hidden: yes
  extends: [order_items]

  join: users {
    view_label: "Kittens"
    from: kitten_users
  }
}
