view: inventory_snapshot {
  derived_table: {
    persist_for: "24 hours"
#     indexes: ["snapshot_date"]
#     distribution: "product_id"
    sql: with calendar as
      (select distinct date(created_at) as snapshot_date
      from inventory_items
      -- where dateadd('day',90,created_at)>=current_date
      )

      select

      inventory_items.product_id
      ,calendar.snapshot_date
      ,count(*) as number_in_stock

      from inventory_items
      left join calendar
      on inventory_items.created_at <= calendar.snapshot_date
      and (inventory_items.sold_at >= calendar.snapshot_date OR inventory_items.sold_at is null)
      -- where dateadd('day',90,calendar.snapshot_date)>=current_date
      group by 1,2

       ;;
  }



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

  dimension: number_in_stock {
    label: "在庫数"
    type: number
    hidden: yes
    sql: ${TABLE}.number_in_stock ;;
  }

  measure: total_in_stock {
    label: "総在庫数"
    type: sum
    sql: ${number_in_stock} ;;
  }

  measure: stock_coverage_ratio {
    label: "在庫カバレッジレシオ"
    type: number
    sql: 1.0 * ${total_in_stock} / nullif(${trailing_sales_snapshot.sum_trailing_28d_sales},0) ;;
    value_format_name: decimal_2
  }

  measure: sum_stock_yesterday {
    label: "昨日付在庫数"
    type: sum
    hidden: yes
    sql: ${number_in_stock} ;;
    filters: {
      field: snapshot_date
      value: "yesterday"
    }
  }


  measure: sum_stock_last_wk {
    label: "先週付在庫数"
    type: sum
    hidden: yes
    sql: ${number_in_stock} ;;
    filters: {
      field: snapshot_date
      value: "8 days ago for 1 day"
    }
  }

  measure: stock_coverage_ratio_yday {
    label: "在庫カバレッジレシオ（Yeasterday）"
    type: number
    view_label: "在庫レシオ比"
    sql: 1.0 * ${sum_stock_yesterday} / nullif(${trailing_sales_snapshot.sum_trailing_28d_sales_yesterday},0) ;;
    value_format_name: decimal_2
  }


  measure: stock_coverage_ratio_last_wk {
    label: "在庫カバレッジレシオ（Last Week）"
    type: number
    view_label: "在庫レシオ比"
    sql: 1.0 * ${sum_stock_last_wk} / nullif(${trailing_sales_snapshot.sum_trailing_28d_sales_last_wk},0) ;;
    value_format_name: decimal_2
  }

  measure: wk_to_wk_change_coverage {
    label: "カバレッジレシオ前週比"
    view_label: "在庫レシオ比"
    sql: round(100*(${stock_coverage_ratio_yday}-${stock_coverage_ratio_last_wk}),1) ;;
    value_format_name: decimal_1
#     value_format: "# 'bp'"
  }


  set: detail {
    fields: [product_id, snapshot_date, number_in_stock]
  }
}