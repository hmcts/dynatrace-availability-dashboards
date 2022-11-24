resource "dynatrace_management_zone" "availability" {
  for_each = {
    for zone in local.management_zones :
    zone.name => zone
  }
  name        = each.value.name
  description = try(each.value.description, null)
  rules {
    enabled           = each.value.enabled
    type              = "HTTP_MONITOR"
    propagation_types = []
    conditions {
      string {
        case_sensitive = true
        negate         = false
        operator       = "CONTAINS"
        value          = each.value.name
      }
      key {
        attribute = "HTTP_MONITOR_NAME"
        type      = "STATIC"
      }
    }
  }
}
