variable "project_id" {
  type        = string
  description = "GCP project ID"
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

variable "ack_deadline_seconds" {
  type        = number
  description = "Acknowledgement deadline in seconds for the subscription"
  default     = 60
}
