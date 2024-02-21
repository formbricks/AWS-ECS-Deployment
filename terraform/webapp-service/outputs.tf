output "application_url" {
  value       = "https://${module.alb.dns_name}"
  description = "Copy this value in your browser in order to access the deployed app"
}
