resource "dynatrace_maintenance" "planned_blackout" {
  /*
   Planned maintenance mode to be used on ad-hoc basis per environment
   in case of cluster upgrades etc. Use this to suppress alerts across
   all synthetic monitors for given environment.
  */
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
      start_time = var.planned_window_start_time
      end_time   = var.planned_window_end_time
      time_zone  = "UTC"
    }
  }
}
