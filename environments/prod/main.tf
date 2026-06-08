terraform {
  required_version = ">= 1.5, < 2.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "current" {}

module "pubsub" {
  source = "../../modules/pubsub"

  project_id        = var.project_id
  topic_name        = var.topic_name
  subscription_name = var.subscription_name
}

module "bigquery" {
  source = "../../modules/bigquery"

  project_id = var.project_id
  dataset_id = var.bq_dataset_id
  table_id   = var.bq_table_id
  location   = "US"
}
