include: "/1_ecomm_demo/1_base_dont_edit/users.view.lkml"
view: +users {

  #### Base Dimensions Refined ####

  dimension: id {
    label: "User ID"
    value_format_name: id
  }

  dimension: first_name {
    label: "First Name"
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${EXTENDED},1,1)), LOWER(SUBSTR(${EXTENDED},2))) ;;
  }

  dimension: last_name {
    label: "Last Name"
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${EXTENDED},1,1)), LOWER(SUBSTR(${EXTENDED},2))) ;;
  }

  dimension: city {
    drill_fields: [zip]
  }

  dimension: state {
    map_layer_name: us_states
    drill_fields: [zip, city]
  }

  dimension: zip {
    type: zipcode
  }

  dimension: country {
    map_layer_name: countries
    drill_fields: [state, city]
    sql: CASE WHEN ${EXTENDED} = 'UK' THEN 'United Kingdom'
           ELSE ${EXTENDED}
           END
       ;;
  }

  dimension_group: created {
  }

  dimension: traffic_source {
  }

  dimension: latitude {
    hidden: yes
  }

  dimension: longitude {
    hidden: yes
  }


  #### Custom Dimensions ####

  dimension: name {
    label: "Name"
    sql: concat(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: over_21 {
    label: "Over 21"
    type: yesno
    sql:  ${age} > 21;;
  }

  dimension: age_tier {
    label: "Age Tier"
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
    sql: ${age} ;;
  }

  dimension: gender_short {
    label: "Gender Short"
    sql: LOWER(SUBSTR(${gender},1,1)) ;;
  }

  dimension: uk_postcode {
    label: "UK Postcode"
    sql: case when ${country} = 'UK' then regexp_replace(${zip}, '[0-9]', '') else null end;;
    map_layer_name: uk_postcode_areas
    drill_fields: [city, zip]
  }

  dimension: location {
    label: "Location"
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: approx_latitude {
    label: "Approx Latitude"
    type: number
    hidden: yes
    sql: round(${latitude},1) ;;
  }

  dimension: approx_longitude {
    label: "Approx Longitude"
    type: number
    hidden: yes
    sql:round(${longitude},1) ;;
  }

  dimension: approx_location {
    label: "Approx Location"
    type: location
    drill_fields: [location]
    sql_latitude: ${approx_latitude} ;;
    sql_longitude: ${approx_longitude} ;;
  }

  dimension: ssn {
    label: "SSN"
    # dummy field used in next dim, generate 4 random numbers to be the last 4 digits
    hidden: yes
    type: string
    sql: CONCAT(CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64),
      CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64));;
  }

#  dimension: ssn_last_4 {
#    label: "SSN Last 4"
#    description: "Only users with sufficient permissions will see this data"
#    type: string
#    sql: CASE WHEN '{{_user_attributes["can_see_sensitive_data"]}}' = 'Yes'
#                THEN ${ssn}
#                ELSE '####' END;;
#  }

  #### MEASURES ####

  measure: count {
    drill_fields: [detail*]
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    type: percent_of_total
    sql: ${count} ;;
    drill_fields: [detail*]
  }

  measure: average_age {
    label: "Average Age"
    type: average
    value_format_name: decimal_2
    sql: ${age} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [id, name, email, age, created_date, order_items.order_count, order_items.count]
  }

}
