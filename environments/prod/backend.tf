terraform {
  backend "gcs" {
    bucket = "pulse-analytics-tfstate"
    prefix = "terraform/prod"
  }
}
