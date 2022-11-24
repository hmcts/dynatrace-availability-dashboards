variable "dynatrace-platops-api-key" { default = null }
variable "env" { default = "demo" }
variable "product" { default = null }
variable "builtFrom" { default = null }

variable "dt_env_url" {
  type = string
}
variable "dt_data_key_vault" {
  type = object({
    name                = string
    resource_group_name = string
    subscription_id     = string
    secret_name         = string
  })
}
