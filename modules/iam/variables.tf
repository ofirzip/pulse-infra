variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "service_account_id" {
  type        = string
  description = "Service account ID (short name, not full email)"
  default     = "pulse-runner"
}

variable "topic_id" {
  type        = string
  description = "Fully qualified Pub/Sub topic ID"
}

variable "subscription_id" {
  type        = string
  description = "Fully qualified Pub/Sub subscription ID"
}

variable "dataset_id" {
  type        = string
  description = "BigQuery dataset ID"
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket name"
}
