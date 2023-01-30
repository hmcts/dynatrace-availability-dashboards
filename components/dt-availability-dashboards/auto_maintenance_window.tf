resource "dynatrace_maintenance" "Auto-Shutdown_Blackout" {
  enabled = true
  filters {
    filter {
      entity_tags = [ "ENVIRONMENT:sbox", "ENVIRONMENT:ptlsbox", "ENVIRONMENT:perftest", "ENVIRONMENT:ithc", "ENVIRONMENT:demo" ]
      entity_type = "HTTP_CHECK"
    }
  }
  general_properties {
    name              = "Auto-Shutdown Blackout"
    description       = "All nonprod envs besides AAT are shutdown between the hours 6:30am-8pm. This maintenance window stops alerting and http monitoring for all HTTP monitors with a tag of ENVIRONMENT in demo, ithc, perftest, sbox, ptlsbox. The maintenance window starts after this as the clusters take some time to build."
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
