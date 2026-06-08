#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="pulse-analytics-prod-498809"
BUCKET_NAME="pulse-analytics-tfstate"
REGION="us-central1"

if ~/google-cloud-sdk/bin/gcloud storage buckets describe "gs://${BUCKET_NAME}" --project="${PROJECT_ID}" &>/dev/null; then
  echo "Bucket gs://${BUCKET_NAME} already exists, skipping creation."
else
  echo "Creating Terraform state bucket: gs://${BUCKET_NAME}"
  ~/google-cloud-sdk/bin/gcloud storage buckets create "gs://${BUCKET_NAME}" \
    --project="${PROJECT_ID}" \
    --location="${REGION}" \
    --uniform-bucket-level-access
fi

~/google-cloud-sdk/bin/gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --versioning

echo "Done. Bucket gs://${BUCKET_NAME} is ready."
