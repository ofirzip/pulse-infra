output "service_account_email" {
  description = "Service account email address"
  value       = google_service_account.pulse_runner.email
}

output "service_account_id" {
  description = "Fully qualified service account resource ID"
  value       = google_service_account.pulse_runner.id
}
