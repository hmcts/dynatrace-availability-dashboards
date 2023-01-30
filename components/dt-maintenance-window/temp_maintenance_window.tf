resource "dynatrace_maintenance" "planned_blackout" {
  # Switch to true to enable the temporary maintenance window
  enabled = false
  filters {
    filter {
      entity_tags = var.blackout_environments
      entity_type = "HTTP_CHECK"
    }
  }
  general_properties {
    name        = "Planned Blackout"
    description = "Temporary Maintenance Window to stop alerting on likely failing HTTP checks"
    type        = "PLANNED"
    # Keep synthetics running during this period but stop alerting
    disable_synthetic = false
    suppression       = "DONT_DETECT_PROBLEMS"
  }
  schedule {
    type = "ONE-OFF"
    once_recurrence {
      # Change this in variables.tf
      end_time   = var.once_end_time
      start_time = var.once_start_time
      time_zone  = "UTC"
    }
  }
}
