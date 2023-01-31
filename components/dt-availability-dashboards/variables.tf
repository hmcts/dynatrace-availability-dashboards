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
variable "planned_maintenance" {
  default     = false
  description = "This is a toggle to enable or disable a planned maintenance window for an environment"
}
variable "dynatrace_platops_api_key" {
  type        = string
  description = "Dynatrace API access key"
}
variable "planned_window_start_time" {
  type        = string
  default     = "2023-01-30T19:00:00"
  description = "Start time of the planned maintenance window"
}
variable "planned_window_end_time" {
  type        = string
  default     = "2023-01-30T20:00:00"
  description = "End time of the planned maintenance window"
}
variable "auto_window_start_time" {
  type        = string
  default     = "20:00:00"
  description = "This is the time that the cluster-shutdown maintenance window (stopped alerting) should begin"
}
variable "auto_window_end_time" {
  type        = string
  default     = "08:30:00"
  description = "This is the time that the cluster-shutdown maintenance window (stopped alerting) should end"
}
variable "auto_window_start_date" {
  type        = string
  default     = "2023-01-31"
  description = "This is the date that the cluster-shutdown maintenance window (stopped alerting) should begin"
}
variable "auto_window_end_date" {
  type        = string
  default     = "2030-01-01"
  description = "This is the date that the cluster-shutdown maintenance window (stopped alerting) should end"
}
