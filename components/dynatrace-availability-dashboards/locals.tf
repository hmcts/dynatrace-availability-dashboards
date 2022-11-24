locals {
  management_zones         = yamldecode(file("${path.module}/../../dynatrace/management_zones/management_zones_${var.env}.yaml"))["management_zones"]
  synthetic_monitors       = yamldecode(file("${path.module}/../../dynatrace/synthetic_monitors/synthetic_monitors_${var.env}.yaml"))["synthetic_monitors"]
  service_level_objectives = yamldecode(file("${path.module}/../../dynatrace/service_level_objectives/service_level_objectives_${var.env}.yaml"))["service_level_objectives"]
}

