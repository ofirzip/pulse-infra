output "topic_id" {
  description = "Fully qualified topic ID"
  value       = google_pubsub_topic.pulse_events.id
}

output "topic_name" {
  description = "Topic name"
  value       = google_pubsub_topic.pulse_events.name
}

output "subscription_id" {
  description = "Fully qualified subscription ID"
  value       = google_pubsub_subscription.pulse_events_sub.id
}

output "subscription_name" {
  description = "Subscription name"
  value       = google_pubsub_subscription.pulse_events_sub.name
}
