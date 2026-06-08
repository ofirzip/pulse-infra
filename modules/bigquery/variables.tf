variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "dataset_id" {
  type        = string
  description = "BigQuery dataset ID"
  default     = "pulse_raw"
}

variable "table_id" {
  type        = string
  description = "BigQuery table ID"
  default     = "events"
}

variable "location" {
  type        = string
  description = "BigQuery dataset location"
  default     = "US"
}
