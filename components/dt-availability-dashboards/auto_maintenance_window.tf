resource "dynatrace_maintenance" "auto_shutdown_blackout" {
  enabled = true
  filters {
    filter {
      entity_tags = ["ENVIRONMENT:${var.env}"]
      entity_type = "HTTP_CHECK"
    }
  }
  general_properties {
    name              = "Auto-Shutdown Blackout for ${var.env} environment."
    description       = "All nonprod envs besides AAT are shutdown out of hours. This maintenance window stops alerting and HTTP monitors for all HTTP monitors in ${var.env} environment. The maintenance window starts after this as the clusters take some time to build."
    type              = "PLANNED"
    disable_synthetic = true
    suppression       = "DONT_DETECT_PROBLEMS"
  }
  schedule {
    type = "DAILY"
    daily_recurrence {
      recurrence_range {
        end_date   = var.auto_window_start_date
        start_date = var.auto_window_end_date
      }
      time_window {
        end_time   = var.auto_window_end_time
        start_time = var.auto_window_start_time
        time_zone  = "UTC"
      }
    }
  }
}
