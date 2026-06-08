locals {
  table_reference = "${var.project_id}.${var.dataset_id}.${var.table_id}"
}

resource "google_bigquery_dataset" "pulse_raw" {
  project    = var.project_id
  dataset_id = var.dataset_id
  location   = var.location

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_bigquery_table" "events" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.pulse_raw.dataset_id
  table_id   = var.table_id

  deletion_protection = false

  schema = jsonencode([
    { name = "event_type", type = "STRING", mode = "NULLABLE" },
    { name = "user_id", type = "STRING", mode = "NULLABLE" },
    { name = "ingested_at", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "session_id", type = "STRING", mode = "NULLABLE" },
    { name = "properties", type = "JSON", mode = "NULLABLE" }
  ])
}
