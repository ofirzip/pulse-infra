#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="pulse-analytics-prod-498809"
BUCKET_NAME="pulse-analytics-tfstate"
REGION="us-central1"

echo "Creating Terraform state bucket: gs://${BUCKET_NAME}"

gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access

gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --versioning

echo "Done. Bucket gs://${BUCKET_NAME} is ready."
