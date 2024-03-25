include: "/1_ecomm_demo/1_base_dont_edit/products.view.lkml"

view: +products {

  #### Base Dimensions Refined ####

  dimension: id {
    label: "Product ID"
  }

  dimension: category {
    # sql: TRIM(${TABLE}.category) ;;
    sql: TRIM(${EXTENDED}) ;;
    drill_fields: [department, brand, item_name]
  }

  dimension: item_name {
    sql: TRIM(${EXTENDED}) ;;
    drill_fields: [id]
  }

  dimension: brand {
    label: "Brand"
    sql: TRIM(${EXTENDED}) ;;
    drill_fields: [item_name]
    link: {
      label: "Website"
      url: "http://www.google.com/search?q={{ value | encode_uri }}+clothes&btnI"
      icon_url: "http://www.google.com/s2/favicons?domain=www.{{ value | encode_uri }}.com"
    }
    link: {
      label: "Facebook"
      url: "http://www.google.com/search?q=site:facebook.com+{{ value | encode_uri }}+clothes&btnI"
      icon_url: "https://upload.wikimedia.org/wikipedia/commons/c/c2/F_icon.svg"
    }
  }

  dimension: retail_price {
    label: "Retail Price"
    type: number
  }

  dimension: department {
    label: "Department"
    sql: TRIM(${EXTENDED}) ;;
  }

  dimension: sku {
    label: "SKU"
  }

  dimension: distribution_center_id {
    label: "Distribution Center ID"
    type: number
    value_format_name: id
    sql: CAST(${EXTENDED} AS INT64) ;;
  }

  #### Custom Dimensions ####




  #### Measures ####

  measure: count {
    label: "Count"
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    label: "Brand Count"
    type: count_distinct
    sql: ${brand} ;;
    drill_fields: [brand, detail2*, -brand_count] # show the brand, a bunch of counts (see the set below), don't show the brand count, because it will always be 1
  }

  measure: category_count {
    label: "Category Count"
    alias: [category.count]
    type: count_distinct
    sql: ${category} ;;
    drill_fields: [category, detail2*, -category_count] # don't show because it will always be 1
  }

  measure: department_count {
    label: "Department Count"
    alias: [department.count]
    type: count_distinct
    sql: ${department} ;;
    drill_fields: [department, detail2*, -department_count] # don't show because it will always be 1
  }

  measure: prefered_categories {
    hidden: yes
    label: "Prefered Categories"
    type: list
    list_field: category
    #order_by_field: order_items.count

  }

  measure: prefered_brands {
    hidden: yes
    label: "Prefered Brand"
    type: list
    list_field: brand
    #order_by_field: count
  }

  #### Sets ####

  set: detail {
    fields: [id, item_name, brand, category, department, retail_price, customers.count, orders.count, order_items.count, inventory_items.count]
  }

  set: detail2 {
    fields: [category_count, brand_count, department_count, count, customers.count, orders.count, order_items.count, inventory_items.count, products.count]
  }


}
