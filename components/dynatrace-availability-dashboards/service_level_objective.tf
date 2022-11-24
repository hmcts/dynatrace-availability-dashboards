resource "dynatrace_slo" "availability" {
  for_each = {
    for management_zone in dynatrace_management_zone.availability :
    management_zone.name => management_zone
  }
  #for_each = {
  #  for slo in local.service_level_objectives :
  #  slo.name => slo
  #}
  name              = "[${each.value.name}] Availability"
  disabled          = false
  metric_expression = "builtin:synthetic.http.availability.location.total:splitBy()"
  evaluation        = "AGGREGATE"
  filter            = "type(HTTP_CHECK), mzName(${each.value.name})"
  target            = 95
  warning           = 97.5
  timeframe         = "-1d"
  #filter            = "mzName(\"${each.value.name}\"),type(\"HTTP_CHECK\")"
}




#resource "dynatrace_slo" "availability" {
#  for_each = {
#    for slo in local.service_level_objectives :
#    slo.name => slo
#  }
#  name              = each.value.name
#  disabled          = each.value.disabled
#  metric_expression = try(each.value.metric_expression, null)
#  evaluation        = each.value.evaluation
#  filter            = each.value.filter
#  target            = each.value.target
#  timeframe         = each.value.timeframe
#  warning           = each.value.warning
#}
