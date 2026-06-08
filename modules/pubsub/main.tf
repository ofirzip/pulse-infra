resource "google_pubsub_topic" "pulse_events" {
  project = var.project_id
  name    = var.topic_name

  message_retention_duration = "604800s" # 7 days
}

resource "google_pubsub_subscription" "pulse_events_sub" {
  project = var.project_id
  name    = var.subscription_name
  topic   = google_pubsub_topic.pulse_events.id

  ack_deadline_seconds = var.ack_deadline_seconds

  expiration_policy {
    ttl = "" # never expires
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}
