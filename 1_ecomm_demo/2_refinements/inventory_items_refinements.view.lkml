include: "/1_ecomm_demo/1_base_dont_edit/inventory_items.view.lkml"

view: +inventory_items {

  #### Base Dimensions Refined ####

  dimension: id {
    label: "Inventory Item ID"
    type: number
  }

  dimension: cost {
    value_format_name: usd
  }

  dimension_group: created {
    label: "Inventory Created"
    timeframes: [time, date, week, month, raw]
  }

  dimension: product_id {
    label: "Product ID"
    hidden: yes
  }

  dimension_group: sold {
    label: "Sold"
    timeframes: [time, date, week, month, raw]
  }

  dimension: product_distribution_center_id {
    label: "Product Distribution Center ID"
    hidden: yes
  }

  #### Custom Dimensions ####

  dimension: is_sold {
    label: "Is Sold"
    type: yesno
    sql: ${sold_raw} is not null ;;
  }

  dimension: days_in_inventory {
    label: "Days in Inventory"
    description: "days between created and sold date"
    type: number
    sql: TIMESTAMP_DIFF(coalesce(${sold_raw}, CURRENT_TIMESTAMP()), ${created_raw}, DAY) ;;
  }

  dimension: days_in_inventory_tier {
    label: "Days In Inventory Tier"
    type: tier
    sql: ${days_in_inventory} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: days_since_arrival {
    label: "Days Since Arrival"
    description: "days since created - useful when filtering on sold yesno for items still in inventory"
    type: number
    sql: TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY) ;;
  }

  dimension: days_since_arrival_tier {
    label: "Days Since Arrival Tier"
    type: tier
    sql: ${days_since_arrival} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  #### Measures ####

  measure: sold_count {
    label: "Sold Count"
    type: count
    drill_fields: [detail*]
    filters: [is_sold: "Yes"]
  }

  measure: sold_percent {
    label: "Sold Percent"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${sold_count}/(CASE WHEN ${count} = 0 THEN NULL ELSE ${count} END) ;;
  }

  measure: total_cost {
    label: "Total Cost"
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: average_cost {
    label: "Average Cost"
    type: average
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: count {
    label: "Count"
    type: count
    drill_fields: [detail*]
  }

  measure: number_on_hand {
    label: "Number On Hand"
    type: count
    drill_fields: [detail*]
    filters: [is_sold: "No"]
  }

  set: detail {
    fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
  }

}
