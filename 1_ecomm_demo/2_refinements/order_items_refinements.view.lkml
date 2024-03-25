include: "/1_ecomm_demo/1_base_dont_edit/order_items.view.lkml"
view: +order_items {

  ########## Base Dimension Refinements ##########

  dimension: id {
    label: "Order Item ID"
    description: "Unique identifier for each order item (5 digits)"
    value_format_name: id
  }

  dimension: inventory_item_id {
    label: "Inventory Item ID"
    description: "Identifier for the associated inventory item (hidden)"
    value_format_name: id
    hidden: yes
  }

  dimension: user_id {
    label: "User ID"
    description: "Identifier for the associated user (hidden)"
    value_format_name: id
    hidden: yes
  }

  dimension: order_id {
    label: "Order ID"
    description: "Order number"
    value_format_name: id
  }

  dimension_group: returned {
    description: "Date and time the item was returned"
  }

  dimension_group: shipped {
    description: "Date and time the item was shipped"
  }

  dimension_group: delivered {
    description: "Date and time the item was delivered"
  }

  dimension_group: created {
    description: "Date and time the item was added to the order"
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw, week_of_year,month_name]
  }

  dimension: status {
    description: "Current status of the order item (Processing, Shipped, etc.)"
  }

  dimension: sale_price {
    description: "Price the item was sold for"
    value_format_name: usd
  }


  ########## Custom Dimensions ##########


  dimension: days_to_process {
    label: "Days to Process"
    description: "Days to Process the order"
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN TIMESTAMP_DIFF(${shipped_raw}, ${created_raw}, DAY)*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
       ;;
  }


  dimension: shipping_time {
    label: "Shipping Time"
    description: "Number of days between the delivery date and shipping date"
    type: number
    sql: TIMESTAMP_DIFF(${delivered_raw}, ${shipped_raw}, DAY)*1.0 ;;
  }

  dimension: gross_margin {
    label: "Gross Margin"
    description: "Profit after subtracting the cost of the item"
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
  }

  dimension: item_gross_margin_percentage {
    label: "Item Gross Margin Percentage"
    description: "Gross margin as a percentage of the sale price"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    label: "Item Gross Margin Percentage Tier"
    description: "Gross margin as a percentage of the sale price tiered out"
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  dimension: is_returned {
    label: "Is Returned"
    description: "Whether the item was returned"
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }




  ########## Custom Measures ##########

  measure: count {
    label: "# of Items"
    description: "Number of order items"
    drill_fields: [detail*]
  }

  measure: order_count {
    description: "# of orders"
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id};;
  }

  measure: average_days_to_process {
    label: "Average Days to Process"
    description: "Average time it takes to process an order"
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    label: "Average Shipping Time"
    description: "Average delivery time after shipping"
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

  measure: total_sale_price {
    label: "Total Sale Price"
    description: "Total revenue from order items"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    label: "Total Gross Margin"
    description: "Total profit from order items"
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    # drill_fields: [detail*]
    drill_fields: [user_id, average_sale_price, total_gross_margin]
  }

  measure: average_sale_price {
    label: "Average Sale Price"
    description: "Average price of an order item"
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: median_sale_price {
    label: "Median Sale Price"
    description: "Median price of an order item"
    type: median
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_gross_margin {
    label: "Average Gross Margin"
    description: "Average profit per order item"
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    label: "Total Gross Margin Percentage"
    description: "Percentage profit per order item"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ nullif(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    label: "Average Spend per User"
    description: "Average spend per user that has purchased"
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / nullif(${users.count},0) ;;
    drill_fields: [detail*]
  }

  measure: returned_count {
    label: "Returned Count"
    description: "Number of items returned"
    type: count_distinct
    sql: ${id} ;;
    filters: [is_returned: "Yes"]
    drill_fields: [detail*]
  }

  measure: returned_total_sale_price {
    label: "Returned Total Sale Price"
    description: "Total value of returned items"
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: [is_returned: "Yes"]
  }

  measure: return_rate {
    label: "Return Rate"
    description: "Percentage of items returned"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
    html: {{link}} ;;
  }

########## Sets ##########

  set: detail {
    fields: [order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
    fields: [id, order_id, status, created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }




}
