locals {
  dashboard_url = "${var.dt_env_url}/#dashboard;id=${dynatrace_dashboard.availability.id}"
}
output "dashboard_url" {
  description = "Dynatrace Dashboard URL"
  value       = local.dashboard_url
}
output "ado_dashboard_url" {
  description = "ADO Warning - Dynatrace Dashboard URL"
  value       = "##vso[task.logissue type=warning] ${var.env} - Dashboard URL: ${local.dashboard_url}"
}
