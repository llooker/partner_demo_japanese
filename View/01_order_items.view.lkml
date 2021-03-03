view: order_items {
  sql_table_name: order_items ;;
  ########## IDs, Foreign Keys, Counts ###########

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    label: "商品数"
    type: count_distinct
    sql: ${id} ;;
    drill_fields: [detail*]
  }

  measure: order_count {
    view_label: "オーダー"
    label: "オーダー数"
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id} ;;
  }


  measure: count_last_28d {
    label: "直近28日内受注商品数"
    type: count_distinct
    sql: ${id} ;;
#     hidden: yes
    filters:
    {field:created_date
      value: "28 days"
    }}

  dimension: order_id {
    label: "オーダーID"
    type: number
    sql: ${TABLE}.order_id ;;


    action: {
      label: "スラックへ送信"
      url: "https://hooks.zapier.com/hooks/catch/1662138/tvc3zj/"

      param: {
        name: "user_dash_link"
        value: "/dashboards/thelook_japanese::user_lookup_dashboard?Email={{ users.email._value}}"
      }

      form_param: {
        name: "メッセージ"
        type: textarea
        default: "Hey,
        Could you check out order #{{value}}. It's saying its {{status._value}},
        but the customer is reaching out to us about it.
        "
      }
# ~{{ _user_attributes.first_name}}
      form_param: {
        name: "受信ユーザ"
        type: select
        default: "zevl"
        option: {
          name: "zevl"
          label: "Zev"
        }
        option: {
          name: "slackdemo"
          label: "Slack Demo User"
        }

      }

      form_param: {
        name: "Channel"
        type: select
        default: "cs"
        option: {
          name: "cs"
          label: "Customer Support"
        }
        option: {
          name: "general"
          label: "General"
        }

      }


    }



  }

  ########## Time Dimensions ##########

  dimension_group: returned {
    label: "返品"
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    label: "出荷"
    type: time
    timeframes: [date, week, month, raw]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension_group: delivered {
    label: "到着"
    type: time
    timeframes: [date, week, month, raw]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: created {
    #X# group_label:"Order Date"
    label: "受注"
    type: time
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw, week_of_year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: reporting_period {
    group_label: "Order Date"
    label: "レポート期間"
    sql: CASE
        WHEN date_part('year',${created_raw}) = date_part('year',current_date)
        AND ${created_raw} < CURRENT_DATE
        THEN 'This Year to Date'

        WHEN date_part('year',${created_raw}) + 1 = date_part('year',current_date)
        AND date_part('dayofyear',${created_raw}) <= date_part('dayofyear',current_date)
        THEN 'Last Year to Date'

      END
       ;;
  }

  dimension: days_since_sold {
    hidden: yes
    sql: datediff('day',${created_raw},CURRENT_DATE) ;;
  }

  dimension: months_since_signup {
    view_label: "オーダー"
    label: "登録から注文までの月数"
    type: number
    sql: DATEDIFF('month',${users.created_raw},${created_raw}) ;;
  }

########## Logistics ##########

  dimension: status {
    label: "ステータス"
    type: string
    sql:
      CASE
        WHEN ${TABLE}.status = 'Processing' THEN 'プロセス中'
        WHEN ${TABLE}.status = 'Shipped' THEN '出荷'
        WHEN ${TABLE}.status = 'Complete' THEN '完了'
        WHEN ${TABLE}.status = 'Returned' THEN '返品'
        WHEN ${TABLE}.status = 'Cancelled' THEN 'キャンセル'
        ELSE null
      END ;;
  }

  parameter: days_to_process_sensitivity {
    label: "プロセス期間上限"
    type: number
    default_value: "10"
  }

  dimension: days_to_process {
    label: "プロセス期間（日）"
    type: number
    sql: CASE
        WHEN ${status} = 'プロセス中' THEN DATEDIFF('day',${created_raw},CURRENT_DATE())*1.0
        WHEN ${status} IN ('出荷', '完了', '返品') THEN DATEDIFF('day',${created_raw},${shipped_raw})*1.0
        WHEN ${status} = 'キャンセル' THEN NULL
      END
       ;;
  }

  dimension: shipping_time {
    label: "発送期間（日）"
    type: number
    sql: datediff('day',${shipped_raw},${delivered_raw})*1.0 ;;
  }

  measure: average_days_to_process {
    label: "平均プロセス期間（日）"
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
    html:
      {% assign var=_filters['order_items.days_to_process_sensitivity'] | plus:0 %}
      {% if var < order_items.average_days_to_process._value %}
      <div style="color: black; background-color: red; font-size:100%; text-align:center">{{ rendered_value }}</div>
      {% else %}
      {{rendered_value}}
      {% endif %} ;;
  }

  measure: average_shipping_time {
    label: "平均発送期間（日）"
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

########## Financial Information ##########

  dimension: sale_price {
    label: "売上"
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price;;
  }

  dimension: gross_margin {
    label: "商品別粗利益"
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    label: "商品別粗利益率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    label: "商品別粗利益率層"
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  measure: total_sale_price {
    label: "総売上"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    label: "粗利益"
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: average_sale_price {
    label: "平均売上"
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

    measure: median_sale_price {
      label: "中央価格値"
      type: median
      value_format_name: usd
      sql: ${sale_price} ;;
      drill_fields: [detail*]
    }

  measure: average_gross_margin {
    label: "平均商品別粗利益"
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    label: "平均商品別粗利率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ NULLIF(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    label: "ユーザー平均消費額"
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / NULLIF(${users.count},0) ;;
    drill_fields: [detail*]
  }

########## Return Information ##########

  dimension: is_returned {
    type: yesno
    label: "返品商品ラベル"
    sql: ${returned_raw} IS NOT NULL ;;
  }

  measure: returned_count {
    label: "返品商品数"
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
    drill_fields: [detail*]
  }

  measure: returned_total_sale_price {
    label: "返品額"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
  }

  measure: return_rate {
    label: "返品率"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
  }


########## Repeat Purchase Facts ##########

  dimension: days_until_next_order {
    label: "発注間日数"
    type: number
    view_label: "リピーター"
    sql: DATEDIFF('day',${created_raw},${repeat_purchase_facts.next_order_raw}) ;;
  }

  dimension: repeat_orders_within_30d {
    label: "30日内リピートラベル"
    type: yesno
    view_label: "リピーター"
    sql: ${days_until_next_order} <= 30 ;;
  }

  measure: count_with_repeat_purchase_within_30d {
    label: "30日内リピート購入数"
    type: count_distinct
    sql: ${id} ;;
    view_label: "リピーター"

    filters: {
      field: repeat_orders_within_30d
      value: "Yes"
    }
  }

  measure: 30_day_repeat_purchase_rate {
    description: "The percentage of customers who purchase again within 30 days"
    view_label: "リピーター"
    label: "30日内リピートユーザー率"
    type: number
    value_format_name: percent_1
    sql: 1.0 * ${count_with_repeat_purchase_within_30d} / NULLIF(${count},0) ;;
    drill_fields: [products.brand, order_count, count_with_repeat_purchase_within_30d]
  }

  measure: first_purchase_count {
    label: "初回購入商品数"
    view_label: "オーダー"
    type: count_distinct
    sql: ${order_id} ;;

    filters: {
      field: order_facts.is_first_purchase
      value: "Yes"
    }
    # customized drill path for first_purchase_count
    drill_fields: [user_id, order_id, created_date, users.traffic_source]
    link: {
      label: "New User's Behavior by Traffic Source"
      url: "
      {% assign vis_config = '{
      \"type\": \"looker_column\",
      \"show_value_labels\": true,
      \"y_axis_gridlines\": true,
      \"show_view_names\": false,
      \"y_axis_combined\": false,
      \"show_y_axis_labels\": true,
      \"show_y_axis_ticks\": true,
      \"show_x_axis_label\": false,
      \"value_labels\": \"legend\",
      \"label_type\": \"labPer\",
      \"font_size\": \"13\",
      \"colors\": [
      \"#1ea8df\",
      \"#a2dcf3\",
      \"#929292\"
      ],
      \"hide_legend\": false,
      \"y_axis_orientation\": [
      \"left\",
      \"right\"
      ],
      \"y_axis_labels\": [
      \"Average Sale Price ($)\"
      ]
      }' %}
      {{ hidden_first_purchase_visualization_link._link }}&vis_config={{ vis_config | encode_uri }}&sorts=users.average_lifetime_orders+descc&toggle=dat,pik,vis&limit=5000"
    }
  }

########## Parameter Aggregation Examples ##########
#   parameter: category_to_count_1 {
#     type: string
#     suggest_dimension: products.category
#   }
#
#   measure: category_count_1 {
#     type: sum
#     sql:
#       CASE
#         WHEN ${products.category} = {% parameter category_to_count_1 %}
#           THEN 1
#         ELSE 0
#       END ;;
#   }
#
#   parameter: category_to_count_2 {
#     type: string
#     suggest_dimension: products.category
#   }
#
#   measure: category_count_2 {
#     type: sum
#     sql:
#     CASE
#       WHEN ${products.category} = {% parameter category_to_count_2 %}
#         THEN 1
#       ELSE 0
#     END ;;
#   }
#
#   measure: accessory_count {
#     label: "アクセサリー数"
#     type: count
#     filters: {
#       field: products.category
#       value: "Accessories"
#     }
#   }
#
#   measure: jeans_count {
#     label: "ジーンズ数"
#     type: count
#     filters: {
#       field: products.category
#       value: "Jeans"
#     }
#   }
#
#   measure: sweaters_count {
#     label: "セーター数"
#     type: count
#     filters: {
#       field: products.category
#       value: "Sweaters"
#     }
#   }

########## Parameter Date Examples ##########
parameter: time_period {
  label: "指定期間"
  allowed_value: {value: "Date"}
  allowed_value: {value: "Week"}
  allowed_value: {value: "Month"}
  allowed_value: {value: "Year"}
}

dimension: cohort_time_period {
  label: "コホート期間"
  sql:
    CASE
      WHEN {% parameter time_period %} = 'Date' THEN ${created_date}::varchar
      WHEN {% parameter time_period %} = 'Week' THEN ${created_week}::varchar
      WHEN {% parameter time_period %} = 'Month' THEN ${created_month}::varchar
      WHEN {% parameter time_period %} = 'Year' THEN ${created_year}::varchar
      ELSE ${created_date}::varchar
    END ;;
}


########## Dynamic Sales Cohort App ##########

  filter: cohort_by {
    type: string
    hidden: yes
    suggestions: ["Week", "Month", "Quarter", "Year"]
  }

  filter: metric {
    type: string
    hidden: yes
    suggestions: ["Order Count", "Gross Margin", "Total Sales", "Unique Users"]
  }

  dimension_group: first_order_period {
    type: time
    timeframes: [date]
    hidden: yes
    sql: CAST(DATE_TRUNC({% parameter cohort_by %}, ${user_order_facts.first_order_date}) AS DATE)
      ;;
  }

  dimension: periods_as_customer {
    type: number
    hidden: yes
    sql: DATEDIFF({% parameter cohort_by %}, ${user_order_facts.first_order_date}, ${user_order_facts.latest_order_date})
      ;;
  }

  measure: cohort_values_0 {
    type: count_distinct
    hidden: yes
    sql: CASE WHEN {% parameter metric %} = 'Order Count' THEN ${id}
        WHEN {% parameter metric %} = 'Unique Users' THEN ${users.id}
        ELSE null
      END
       ;;
  }

  measure: cohort_values_1 {
    type: sum
    hidden: yes
    sql: CASE WHEN {% parameter metric %} = 'Gross Margin' THEN ${gross_margin}
        WHEN {% parameter metric %} = 'Total Sales' THEN ${sale_price}
        ELSE 0
      END
       ;;
  }

  measure: values {
    type: number
    hidden: yes
    sql: ${cohort_values_0} + ${cohort_values_1} ;;
  }

  measure: hidden_first_purchase_visualization_link {
    hidden: yes
    view_label: "Orders"
    type: count_distinct
    sql: ${order_id} ;;

    filters: {
      field: order_facts.is_first_purchase
      value: "Yes"
    }
    drill_fields: [users.traffic_source, user_order_facts.average_lifetime_revenue, user_order_facts.average_lifetime_orders]
  }




########## Sets ##########

  set: detail {
    fields: [id, order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
      fields: [id, order_id, status, created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
}
