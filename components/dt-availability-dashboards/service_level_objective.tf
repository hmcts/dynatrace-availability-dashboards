resource "time_sleep" "management_zones" {
  for_each = {
    for management_zone in dynatrace_management_zone.availability :
    management_zone.name => management_zone
  }
  create_duration  = "15s"
  destroy_duration = "15s"
  triggers = {
    name = each.value.name
  }
}

resource "dynatrace_slo" "availability" {
  // SLOs cannot be created before management zones, which can take some time to create
  for_each = {
    for management_zone in time_sleep.management_zones :
    management_zone.triggers.name => management_zone
  }
  name              = "[${each.value.triggers.name}] Availability"
  disabled          = false
  metric_expression = "builtin:synthetic.http.availability.location.total:splitBy()"
  evaluation        = "AGGREGATE"
  filter            = "type(HTTP_CHECK), mzName(${each.value.triggers.name})"
  target            = 95
  warning           = 97.5
  timeframe         = "-1d"
}
