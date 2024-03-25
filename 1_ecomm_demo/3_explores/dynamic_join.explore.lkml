include: "/1_ecomm_demo/1_base_dont_edit/**.view"
include: "/1_ecomm_demo/2_refinements/**/**.view"

explore: dynamic_view {
  label: "Dynamic Base Table Explore"
  description: "This Explore changes its base table depending on a user inputted parameter"
  always_filter: {
    filters: [dynamic_view.table_selector: "Users"]
  }
  fields: [ALL_FIELDS*,-order_items.gross_margin,-order_items.average_spend_per_user]
  join: order_items {
    type: left_outer
    relationship: one_to_many
    sql_on: {% if dynamic_view.table_selector._parameter_value == 'users' %}
                ${dynamic_view.id} = ${order_items.user_id}
            {% elsif dynamic_view.table_selector._parameter_value == 'inventory_items' %}
                ${dynamic_view.id} = ${order_items.inventory_item_id}
            {% else %}
                ${dynamic_view.id} = ${order_items.user_id}
            {% endif %};;
    # sql_on: ${dynamic_view.id} = ${order_items.user_id} ;;
    }
  }
