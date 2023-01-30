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
