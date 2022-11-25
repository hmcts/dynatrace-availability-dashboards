locals {
  config_path        = "../../dynatrace"
  management_zones   = yamldecode(file("${path.module}/${local.config_path}/management_zones/management_zones_${var.env}.yaml"))["management_zones"]
  synthetic_monitors = yamldecode(file("${path.module}/${local.config_path}/synthetic_monitors/synthetic_monitors_${var.env}.yaml"))["synthetic_monitors"]
}

