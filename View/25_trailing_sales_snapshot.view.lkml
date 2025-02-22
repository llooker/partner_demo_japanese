view: trailing_sales_snapshot {
  derived_table: {
    persist_for: "24 hours"
#     indexes: ["product_id"]
#     distribution: "product_id"
    sql: with calendar as
      (select distinct date(created_at) as snapshot_date
      from inventory_items
      -- where dateadd('day',90,created_at)>=current_date
      )

      select


      inventory_items.product_id
      ,date(order_items.created_at) as snapshot_date
      ,count(*) as trailing_28d_sales

      from order_items
      left join inventory_items on order_items.inventory_item_id = inventory_items.id
      left join calendar
      on order_items.created_at <= dateadd('day',28,calendar.snapshot_date)
      and order_items.created_at >= calendar.snapshot_date
      -- where dateadd('day',90,calendar.snapshot_date)>=current_date
      group by 1,2

 ;;
  }

#   measure: count {
#     type: count
#     drill_fields: [detail*]
#   }

  dimension: product_id {
    label: "製品ID"
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: snapshot_date {
    label: "スナップショット"
    type: date
    sql: ${TABLE}.snapshot_date ;;
  }

  dimension: trailing_28d_sales {
    label: "直近28日売上"
    type: number
    hidden: yes
    sql: ${TABLE}.trailing_28d_sales ;;
  }

  measure: sum_trailing_28d_sales {
    label: "直近28日総売上"
    type: sum
    sql: ${trailing_28d_sales} ;;
  }

  measure: sum_trailing_28d_sales_yesterday {
    label: "昨日直近28日総売上"
    type: sum
    hidden: yes
    sql: ${trailing_28d_sales} ;;
    filters: {
      field: snapshot_date
      value: "yesterday"
    }
  }


  measure: sum_trailing_28d_sales_last_wk {
    label: "昨週直近28日総売上"
    type: sum
    hidden: yes
    sql: ${trailing_28d_sales} ;;
    filters: {
      field: snapshot_date
      value: "8 days ago for 1 day"
    }
  }

  set: detail {
    fields: [product_id, snapshot_date, trailing_28d_sales]
  }
}