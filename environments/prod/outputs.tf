output "pubsub_topic_id" {
  description = "Pub/Sub topic ID"
  value       = module.pubsub.topic_id
}

output "pubsub_subscription_id" {
  description = "Pub/Sub subscription ID"
  value       = module.pubsub.subscription_id
}

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.bigquery.dataset_id
}

output "bigquery_table_reference" {
  description = "Fully qualified BigQuery table reference"
  value       = module.bigquery.table_reference
}

output "firestore_database_name" {
  description = "Firestore database name"
  value       = module.firestore.database_name
}

output "storage_bucket_name" {
  description = "GCS reports bucket name"
  value       = module.storage.bucket_name
}

output "storage_bucket_url" {
  description = "GCS reports bucket URL"
  value       = module.storage.bucket_url
}

output "service_account_email" {
  description = "Pulse runner service account email"
  value       = module.iam.service_account_email
}
