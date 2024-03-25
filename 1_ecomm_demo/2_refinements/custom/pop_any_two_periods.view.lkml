include: "/1_ecomm_demo/1_base_dont_edit/order_items.view.lkml"
include: "/1_ecomm_demo/2_refinements/order_items_refinements.view.lkml"

view: pop_any_two_periods {
  view_label: "Z) Period over Period Analysis"

  # filters are two inputs for our users to enter their date ranges

  filter: select_period {
    type: date
    label: "Select Period"
    description: "Select the 1st date range you are interested in comparing.  Comparison and Selected Periods Must not Overlap. Make sure any other filter on Date covers this period, or is removed."
  }

  filter: compare_period {
    type: date
    label: "Compare Period"
    description: "Select the 2nd date range you are interested in Comparing with your Selected Period. Comparison and Selected Period Must not Overlap. Make sure any other filter on Date covers this period, or is removed."
  }

  # this dimension allows us to create a field we can group by to show measure values for a specific date field during the two different periods.
  # Can parmaterize the date if we want similar to how we paramaterize the dynamic measure below

  dimension: dim_date_in_selected_vs_compare_period {
    label: "Selected vs Comparison Period"
    description: "Use with any measure to compare that metrics value for the selected vs comparison period"
    type: string
    case: {
      when: {
        label: "Selected Period"
        sql: {% condition select_period %} ${order_items.created_raw} {% endcondition %} ;;
      }
      when: {
        label: "Comparison Period"
        sql: {% condition compare_period %} ${order_items.created_raw} {% endcondition %};;
      }
      else: "Outside Current and Previous Period"
    }
  }

  dimension: day_in_period {
    type: number
    sql: CASE
              WHEN {% condition select_period %} ${order_items.created_raw} {% endcondition %}
                THEN DATE_DIFF(${order_items.created_raw},{% date_start select_period %}, DAY) +1
              WHEN {% condition compare_period %} ${order_items.created_raw} {% endcondition %}
                THEN DATE_DIFF(${order_items.created_raw},{% date_start compare_period %}, DAY) + 1
              ELSE NULL END;;
  }

  dimension: select_period_duration {
    type: duration_day
    hidden: yes
    sql_start: {% date_start select_period %} ;;
    sql_end:  {% date_end select_period %};;
  }

  dimension: compare_period_duration {
    type: duration_day
    hidden: yes
    sql_start: {% date_start compare_period %} ;;
    sql_end:  {% date_end compare_period %};;
  }

  dimension: selected_period {
    type: string
    sql:  CAST(DATE({% date_start select_period %}) AS string)
          || ' to '
          || CAST(DATE({% date_end select_period %}) AS string)
          || ' ('
          || CAST(${select_period_duration} AS string)
          || ' Days)' ;;
  }

  dimension: comparison_period {
    type: string
    sql:  CAST(DATE({% date_start compare_period %}) AS string)
          || ' to '
          || CAST(DATE({% date_end compare_period %}) AS string)
          || ' ('
          || CAST(${compare_period_duration} AS string)
          || ' Days)' ;;
  }

  # This measure selector parameter and dynamic measure are just used for the dahboard tool.
  # In the explore a user can already choose any available metric for PoP with the above.
  # But this allows a dashboard user to do the same with allowed measures we specify here

  parameter: measure_selector {
    label: "Measure Selector"
    type: string
    description: "Use with Dashboards Only"
    allowed_value: {value:"Total Sales"}
    allowed_value: {value:"Total Gross Margin"}
    allowed_value: {value:"Total Orders"}
    default_value: "Total Sales"
  }

  dimension: selected_measure {
    type: string
    sql: {% parameter measure_selector %} ;;
  }

  measure: dynamic_measure {
    label_from_parameter: measure_selector
    description: "Use with Dashboards Only"
    type: number
    value_format_name: decimal_2
    sql:
         {% if measure_selector._parameter_value == "'Total Sales'" %}
            ${order_items.total_sale_price}
         {% elsif measure_selector._parameter_value == "'Total Gross Margin'" %}
            ${order_items.total_gross_margin}
         {% elsif measure_selector._parameter_value == "'Total Orders'" %}
            ${order_items.order_count}
         {% else %}
            ${order_items.total_sale_price}
         {% endif %};;
  }

}
