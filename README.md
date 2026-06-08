# pulse-infra

Terraform IaC for the GCP resources backing [pulse-demo](https://github.com/ofirzip/pulse-demo).

## Resources

| Resource | Type | Name |
|---|---|---|
| Pub/Sub topic | `google_pubsub_topic` | `pulse-events` |
| Pub/Sub subscription | `google_pubsub_subscription` | `pulse-events-sub` |
| BigQuery dataset | `google_bigquery_dataset` | `pulse_raw` |
| BigQuery table | `google_bigquery_table` | `events` |
| Firestore database | `google_firestore_database` | `(default)` |
| GCS bucket | `google_storage_bucket` | `pulse-analytics-reports` |
| Service account | `google_service_account` | `pulse-runner` |

## Structure

```
environments/prod/   ← Terraform entry point
modules/
  pubsub/            ← topic + subscription
  bigquery/          ← dataset + table
  firestore/         ← native-mode database
  storage/           ← reports bucket
  iam/               ← service account + bindings
bootstrap/           ← one-time state bucket creation
```

## Prerequisites

1. GCP project `pulse-analytics-prod-498809` with billing enabled
2. APIs enabled: Pub/Sub, BigQuery, Firestore, Cloud Storage, IAM, Cloud Resource Manager
3. Application Default Credentials: `gcloud auth application-default login`

## Usage

```bash
# One-time bootstrap (creates GCS state bucket)
bash bootstrap/create_state_bucket.sh

# Standard workflow
cd environments/prod
terraform init
terraform plan
terraform apply
```
