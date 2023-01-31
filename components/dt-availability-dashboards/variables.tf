variable "product" {
  type        = string
  default     = null
  description = "product variable required by cnp terraform template. Not in use by terraform"
}
variable "builtFrom" {
  type        = string
  default     = null
  description = "builtFrom variable required by cnp terraform template. Not in use by terraform"
}
variable "env" {
  type        = string
  description = "Name of the environment to build in"
}
variable "dt_env_url" {
  type        = string
  description = "Dynatrace environment URL"
}
variable "dynatrace_platops_api_key" {
  type        = string
  description = "Dynatrace API access key"
}
variable "once_start_time" {
  type        = string
  default     = "00:00:00"
  description = "Start time of the planned maintenance window"
}
variable "once_end_time" {
  type        = string
  default     = "00:00:00"
  description = "End time of the planned maintenance window"
}
variable "blackout_environments" {
  type        = list(string)
  default     = ["ENVIRONMENT:sbox"]
  description = "Environments to be included in a planned maintenance window"
}
