output "dashboard_url" {
  description = "Dynatrace Dashboard URL"
  value       = "${var.dt_env_url}/#dashboard;id=${dynatrace_dashboard.availability.id}"
}
