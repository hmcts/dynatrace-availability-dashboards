terraform {
  backend "azurerm" {}
  required_version = "1.3.6"
  required_providers {
    dynatrace = {
      version = "1.16.0"
      source  = "dynatrace-oss/dynatrace"
    }
  }
}
provider "dynatrace" {
  dt_env_url   = var.dt_env_url
  dt_api_token = var.dynatrace_platops_api_key
}
