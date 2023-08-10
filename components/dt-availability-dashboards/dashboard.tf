resource "dynatrace_dashboard" "availability" {
  lifecycle {
    ignore_changes = [dashboard_metadata[0].unknowns]
  }
  dashboard_metadata {
    name   = "${upper(var.env)} - Environment Availability"
    shared = true
    preset = true
    owner  = "PlatformOperations"
    tags   = ["environment=${var.env}"]
    unknowns = jsonencode({
      popularity = 1
    })
  }
  dynamic "tile" {
    iterator = slo
    for_each = dynatrace_slo.availability
    content {
      name = "Service-level objective - ${slo.value.name}"
      unknowns = jsonencode({
        isAutoRefreshDisabled = false
      })
      tile_type  = "SLO"
      name_size  = "small"
      configured = true
      filter {
        timeframe = "-30d"
      }
      bounds {
        # automatically compute position of tile depending of odd/even number of slo index.
        top    = length(split(".", tostring(index(keys(dynatrace_slo.availability), slo.key) / 2))) > 1 ? 76 * index(keys(dynatrace_slo.availability), slo.key) - 76 : 76 * index(keys(dynatrace_slo.availability), slo.key)
        left   = length(split(".", tostring(index(keys(dynatrace_slo.availability), slo.key) / 2))) > 1 ? 0 : 304
        width  = 304
        height = 152
      }
      assigned_entities = [slo.value.id]
      metric            = "METRICS=true;LEGEND=true;PROBLEMS=true;decimals=10;customTitle=${slo.value.name};"
    }
  }
}
