output "dataset_id" {
  description = "BigQuery dataset ID"
  value       = google_bigquery_dataset.pulse_raw.dataset_id
}

output "table_id" {
  description = "BigQuery table ID"
  value       = google_bigquery_table.events.table_id
}

output "table_reference" {
  description = "Fully qualified table reference (project.dataset.table)"
  value       = local.table_reference
}
