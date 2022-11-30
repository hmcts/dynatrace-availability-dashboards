resource "time_sleep" "wait_for_management_zones" {
  depends_on       = [dynatrace_management_zone.availability]
  create_duration  = "90s"
  destroy_duration = "90s"
  triggers = {
    zones = filebase64sha256("${path.module}/${local.config_path}/management_zones/management_zones_${var.env}.yaml")
  }
}

resource "dynatrace_slo" "availability" {
  // SLOs cannot be created before management zones, which can take some time to create
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
