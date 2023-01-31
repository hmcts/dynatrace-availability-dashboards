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
        end_date   = "2025-01-01"
        start_date = "2023-01-25"
      }
      time_window {
        end_time   = "08:30:00"
        start_time = "20:00:00"
        time_zone  = "UTC"
      }
    }
  }
}
