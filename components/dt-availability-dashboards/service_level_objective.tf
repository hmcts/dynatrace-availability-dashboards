resource "time_sleep" "wait_for_management_zones" {
  depends_on      = [dynatrace_management_zone.availability]
  create_duration = "30s"
}

resource "dynatrace_slo" "availability" {
  // SLOs cannot be created before management zones, which can take some time to create
  depends_on = [time_sleep.wait_for_management_zones]
  for_each = {
    for management_zone in dynatrace_management_zone.availability :
    management_zone.name => management_zone
  }
  name              = "[${each.value.name}] Availability"
  disabled          = false
  metric_expression = "builtin:synthetic.http.availability.location.total:splitBy()"
  evaluation        = "AGGREGATE"
  filter            = "type(HTTP_CHECK), mzName(${each.value.name})"
  target            = 95
  warning           = 97.5
  timeframe         = "-1d"
}
