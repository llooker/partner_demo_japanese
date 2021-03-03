view: distribution_centers {
  dimension: location {
    label: "ロケーション"
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    label: "名前"
    sql: ${TABLE}.name ;;
  }
}
