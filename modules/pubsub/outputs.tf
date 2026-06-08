output "topic_id" {
  value = google_pubsub_topic.pulse_events.id
}

output "topic_name" {
  value = google_pubsub_topic.pulse_events.name
}

output "subscription_id" {
  value = google_pubsub_subscription.pulse_events_sub.id
}

output "subscription_name" {
  value = google_pubsub_subscription.pulse_events_sub.name
}
