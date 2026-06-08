variable "project_id" {
  type = string
}

variable "topic_name" {
  type    = string
  default = "pulse-events"
}

variable "subscription_name" {
  type    = string
  default = "pulse-events-sub"
}

variable "ack_deadline_seconds" {
  type    = number
  default = 60
}
