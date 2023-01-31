resource "dynatrace_maintenance" "planned_blackout" {
  enabled = var.planned_maintenance
  filters {
    filter {
      entity_tags = ["ENVIRONMENT:${var.env}"]
      entity_type = "HTTP_CHECK"
    }
  }
  general_properties {
    name        = "Planned Blackout in ${var.env}"
    description = "Temporary planned Maintenance Window to stop alerting on likely failing HTTP checks for ${var.env}"
    type        = "PLANNED"
    # Keep synthetics running during this period but stop alerting
    disable_synthetic = false
    suppression       = "DONT_DETECT_PROBLEMS"
  }
  schedule {
    type = "ONCE"
    once_recurrence {
      # Change this in {env}.tfvars
      end_time   = var.planned_window_end_time
      start_time = var.planned_window_start_time
      time_zone  = "UTC"
    }
  }
}
