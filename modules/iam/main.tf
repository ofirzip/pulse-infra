resource "google_service_account" "pulse_runner" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Pulse Runtime SA"
}

resource "google_pubsub_topic_iam_member" "publisher" {
  project = var.project_id
  topic   = var.topic_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.pulse_runner.email}"

  depends_on = [google_service_account.pulse_runner]
}

resource "google_pubsub_subscription_iam_member" "subscriber" {
  project      = var.project_id
  subscription = var.subscription_id
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.pulse_runner.email}"

  depends_on = [google_service_account.pulse_runner]
}

resource "google_bigquery_dataset_iam_member" "bq_editor" {
  project    = var.project_id
  dataset_id = var.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.pulse_runner.email}"

  depends_on = [google_service_account.pulse_runner]
}

locals {
  project_roles = toset([
    "roles/datastore.user",
    "roles/bigquery.jobUser",
  ])
}

resource "google_project_iam_member" "project_roles" {
  for_each = local.project_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.pulse_runner.email}"

  depends_on = [google_service_account.pulse_runner]
}

resource "google_storage_bucket_iam_member" "object_admin" {
  bucket = var.bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.pulse_runner.email}"

  depends_on = [google_service_account.pulse_runner]
}
