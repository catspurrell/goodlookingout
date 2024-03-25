view: rank_top_brands {

  derived_table: {
    explore_source: order_items {
      bind_all_filters: yes
      column: brand { field: products.brand }
      column: order_count {}
      derived_column: ranking {
        sql: rank() over (order by order_count desc) ;;
      }
    }
  }

  dimension: brand_ranked {
    label: "Brand"
    description: "Brand field sorted by total orders"
    order_by_field: ranking
    sql: ${TABLE}.brand ;;
  }

  dimension: order_count {
    hidden: yes
    description: "# of orders"
    type: number
    sql: ${TABLE}.order_count ;;
  }

  dimension: ranking {
    label: "Brand Ranking by Order Count"
    type: number
    sql: ${TABLE}.ranking ;;
  }

  measure: total_orders {
    view_label: "Total Orders"
    type: sum
    sql: ${order_count} ;;
  }


}
