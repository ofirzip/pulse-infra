variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "location_id" {
  type        = string
  description = "Firestore database location (nam5 = US multi-region)"
  default     = "nam5"
}
