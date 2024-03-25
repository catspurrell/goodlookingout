include: "/1_ecomm_demo/1_base_dont_edit/inventory_items.view.lkml"
include: "/1_ecomm_demo/1_base_dont_edit/users.view.lkml"

view: dynamic_view {
  # extends: [inventory_items,users]
  sql_table_name: `looker-private-demo.ecomm.{% parameter table_selector %}` ;;

  parameter: table_selector {
    view_label: "1) Select a Table"
    type: unquoted
    allowed_value: {label:"Inventory Items" value: "inventory_items"}
    allowed_value: {label:"Users" value: "users"}
    default_value: "users"
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    view_label: "Inventory Items"
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: first_name {
    view_label: "Users"
    type: string
    sql: ${TABLE}.first_name ;;
  }



}
