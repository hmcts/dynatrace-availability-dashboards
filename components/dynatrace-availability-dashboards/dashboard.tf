resource "dynatrace_dashboard" "availability" {
  dashboard_metadata {
    name   = "${upper(var.env)} Environment Availability"
    shared = true
    owner  = "Dynatrace"
    tags = [
      "environment=${var.env}"
    ]
  }
  dynamic "tile" {
    iterator = slo
    for_each = dynatrace_slo.availability
    content {
      name       = "Service-level objective - ${slo.value.name}"
      tile_type  = "SLO"
      name_size  = "small"
      configured = true

      filter {
        timeframe = "-1w"
      }

      bounds {
        top = length(split(".", tostring(index(keys(dynatrace_slo.availability), slo.key) / 2))) > 1 ? 76 * index(keys(dynatrace_slo.availability), slo.key) - 76 : 76 * index(keys(dynatrace_slo.availability), slo.key)
        #top    = 152 * index(keys(dynatrace_slo.availability), slo.key)
        left = length(split(".", tostring(index(keys(dynatrace_slo.availability), slo.key) / 2))) > 1 ? 0 : 304
        #left   = 0
        width  = 304
        height = 152
      }
      assigned_entities = [slo.value.id]
      metric            = "METRICS=true;LEGEND=true;PROBLEMS=true;decimals=10;customTitle=${slo.value.name};"
    }
  }
}
