terraform {
  backend "azurerm" {}
  required_version = "1.3.5"
  required_providers {
    dynatrace = {
      version = "1.14.1"
      source  = "dynatrace-oss/dynatrace"
    }
  }
}
provider "dynatrace" {
  dt_env_url   = var.dt_env_url
  dt_api_token = var.DYNATRACE_PLATOPS_API_KEY
}
