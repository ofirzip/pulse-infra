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
  type    = string
  default = "pulse-events"
}

variable "subscription_name" {
  type    = string
  default = "pulse-events-sub"
}

variable "bq_dataset_id" {
  type    = string
  default = "pulse_raw"
}

variable "bq_table_id" {
  type    = string
  default = "events"
}

variable "bucket_name" {
  type    = string
  default = "pulse-analytics-reports"
}

variable "firestore_location" {
  type    = string
  default = "nam5"
}
