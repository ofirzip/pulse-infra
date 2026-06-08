variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for resources"
  default     = "us-central1"
}

variable "topic_name" {
  type        = string
  description = "Pub/Sub topic name"
  default     = "pulse-events"
}

variable "subscription_name" {
  type        = string
  description = "Pub/Sub subscription name"
  default     = "pulse-events-sub"
}

variable "bq_dataset_id" {
  type        = string
  description = "BigQuery dataset ID"
  default     = "pulse_raw"
}

variable "bq_table_id" {
  type        = string
  description = "BigQuery table ID"
  default     = "events"
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket name for reports"
  default     = "pulse-analytics-reports"
}

variable "firestore_location" {
  type        = string
  description = "Firestore database location (nam5 = US multi-region)"
  default     = "nam5"
}
