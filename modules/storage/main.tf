resource "google_storage_bucket" "reports" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.location
  uniform_bucket_level_access = true
  force_destroy               = true

  versioning {
    enabled = false
  }
}
