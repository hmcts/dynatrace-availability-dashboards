output "dashboard_url" {
  description = "Dynatrace Dashboard URL"
  value       = local.dashboard_url
}
output "ado_dashboard_url" {
  description = "Used to display created dashboard URLs as vso[task.logissue type=warning]"
  value       = "##vso[task.logissue type=warning] ${var.env} - dashboard url: ${local.dashboard_url}"
}
