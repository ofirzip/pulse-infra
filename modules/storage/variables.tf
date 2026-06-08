variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "bucket_name" {
  type        = string
  description = "GCS bucket name for reports"
  default     = "pulse-analytics-reports"
}

variable "location" {
  type        = string
  description = "GCS bucket location (US = multi-region, required for free tier)"
  default     = "US"
}
