resource "dynatrace_http_monitor" "availability" {
  for_each = {
    for monitor in local.synthetic_monitors :
    monitor.name => monitor
  }
  enabled   = each.value.enabled
  name      = "${each.value.management_zone_name}-${each.value.name}"
  frequency = 1
  locations = each.value.locations
  anomaly_detection {
    loading_time_thresholds {
      enabled = true
    }
    outage_handling {
      global_outage = true
      local_outage  = true
      local_outage_policy {
        affected_locations = 1
        consecutive_runs   = 3
      }
    }
  }
  tags {
    tag {
      # hardcoded tags created by dynatrace instance.
      context = "CONTEXTLESS"
      key     = "SVCOFF1"
      source  = "RULE_BASED"
      value   = "SVCOFF0001322"
    }
  }
  dynamic "tags" {
    # support non required tags
    iterator = tag
    for_each = try(each.value.tags, [])
    content {
      tag {
        key     = try(tag.value.key, null)
        context = try(tag.value.context, null)
        source  = try(tag.value.source, null)
        value   = try(tag.value.value, null)
      }
    }
  }
  script {
    dynamic "request" {
      for_each = each.value.requests
      content {
        url         = request.value.url
        method      = request.value.method
        description = request.value.description
        configuration {
          accept_any_certificate = try(request.value.configuration.accept_any_certificate, false)
          follow_redirects       = try(request.value.configuration.follow_redirects, true)
          user_agent             = try(request.value.configuration.user_agent, null)
        }
        validation {
          dynamic "rule" {
            for_each = request.value.rules
            content {
              type          = rule.value.type
              value         = rule.value.value
              pass_if_found = rule.value.pass_if_found
            }
          }
        }
      }
    }
  }
}
