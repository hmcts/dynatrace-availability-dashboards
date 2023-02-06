resource "dynatrace_maintenance" "auto_shutdown_blackout" {
  /*
   maintenance mode enabled for given environment to acommodate the
   out of hours AKS cluster shutdown's during weekdays
   See :https://github.com/hmcts/aks-auto-shutdown
  */
  enabled = var.automated_weekday_maintenance
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
        start_date = var.auto_window_start_date
        end_date   = var.auto_window_end_date
      }
      time_window {
        start_time = var.auto_window_start_time
        end_time   = var.auto_window_end_time
        time_zone  = "UTC"
      }
    }
  }
}

resource "dynatrace_maintenance" "auto_shutdown_weekends" {
  /*
   maintenance mode enabled for given environment to acommodate the
   out of hours AKS cluster shutdown's during weekends when we power off
   See :https://github.com/hmcts/aks-auto-shutdown
  */
  enabled  = var.automated_weekend_maintenance
  for_each = local.weekend_days
  filters {
    filter {
      entity_tags = ["ENVIRONMENT:${var.env}"]
      entity_type = "HTTP_CHECK"
    }
  }
  general_properties {
    name              = "Auto-Shutdown Blackout for ${var.env} environment over the weekends"
    description       = "All nonprod envs besides AAT are shutdown out of hours. This maintenance window stops alerting and HTTP monitors for all HTTP monitors in ${var.env} environment"
    type              = "PLANNED"
    disable_synthetic = true
    suppression       = "DONT_DETECT_PROBLEMS"
  }
  schedule {
    type = "WEEKLY"
    weekly_recurrence {
      day_of_week = each.key
      recurrence_range {
        start_date = var.auto_window_start_date
        end_date   = var.auto_window_end_date
      }
      time_window {
        start_time = var.weekend_window_start_time
        end_time   = var.weekend_window_end_time
        time_zone  = "UTC"
      }
    }
  }
}
