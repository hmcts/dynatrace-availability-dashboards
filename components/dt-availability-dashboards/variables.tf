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
  description = "Environment key"
}
variable "dt_env_url" {
  type        = string
  description = "Dynatrace environment URL"

}
variable "dynatrace_platops_api_key" {
  type        = string
  description = "Dynatrace API access key"
}
