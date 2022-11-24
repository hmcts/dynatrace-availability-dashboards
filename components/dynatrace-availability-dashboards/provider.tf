terraform {
  backend "azurerm" {}
  required_version = "1.3.5"
  required_providers {
    dynatrace = {
      version = "1.14.1"
      source  = "dynatrace-oss/dynatrace"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.32.0"
    }
  }
}
provider "azurerm" {
  features {}
  subscription_id = var.dt_data_key_vault.subscription_id
}
provider "dynatrace" {
  dt_env_url   = var.dt_env_url
  dt_api_token = var.dynatrace-platops-api-key
}
