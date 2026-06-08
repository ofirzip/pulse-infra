---
title: Pulse Infrastructure — GCP + Terraform IaC
date: 2026-06-08
status: approved
project_id: pulse-analytics-prod-498809
---

# Pulse Infrastructure Design Spec

## Overview

Terraform IaC for the GCP resources backing the `pulse-demo` Python analytics backend. The repo is structured to mirror real production Terraform repos so it can also serve as a scan target for VAST's IaC scanner.

## Goals

- Provision all GCP resources required by `pulse-demo` (Pub/Sub, BigQuery, Firestore, Cloud Storage, IAM)
- Stay within GCP Always Free tier for light/demo workloads
- Expose diverse Terraform patterns (modules, outputs, data sources, locals, for_each, lifecycle) for scanner coverage
- Use least-privilege IAM — all bindings scoped to individual resources, not project-wide roles

## Non-Goals

- No CI/CD pipeline (manual `terraform apply` only)
- No multi-environment promotion workflow (prod only)
- No VPC, Cloud Run, or Cloud Functions resources (application hosting out of scope)

---

## GCP Account Setup (Manual Prerequisites)

These steps are performed once by hand before any Terraform is run.

### 1. Create GCP project
Project ID: `pulse-analytics-prod-498809`
Already created via GCP Console.

### 2. Enable billing
A credit card must be on file even for free-tier usage. No charges occur within free-tier limits.

### 3. Enable required APIs
```bash
gcloud config set project pulse-analytics-prod-498809
gcloud config set compute/region us-central1
gcloud config set compute/zone us-central1-a

gcloud services enable \
  pubsub.googleapis.com \
  bigquery.googleapis.com \
  firestore.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com
```

### 4. Authenticate for local Terraform use
```bash
gcloud auth application-default login
```

### 5. Bootstrap Terraform state bucket (one-time)
Run `bootstrap/create_state_bucket.sh` before the first `terraform init`.
This creates the GCS bucket that stores `.tfstate`. It cannot be managed by Terraform itself (chicken-and-egg).

---

## Free Tier — Non-Traffic Cost Factors

| Factor | Impact | Action |
|---|---|---|
| **BigQuery streaming inserts** | ⚠️ NOT free — $0.01/200 MB | `insert_rows_json` in `consumer.py` is billed even at low volume. Acceptable for demo traffic, but note for production. |
| **GCS bucket location** | Must be `US` multi-region | `pulse-analytics-reports` bucket set to `location = "US"`. Single regions (e.g. `us-east1`) do not qualify for free tier. |
| **Firestore mode** | Irreversible choice | Must use **Native mode**. Cannot be changed after creation. Datastore mode is legacy. |
| **GCS Class A operations** | 5,000/month free | Each `upload_from_string` = 1 Class A op. At 1 report/day = ~30 ops/month. Well within limit. |
| **Cloud Logging volume** | 50 GB/month free | If Pulse runs in Cloud Functions, stdout → Cloud Logging. Verbose logging can exceed free tier. |
| **Terraform state bucket** | Negligible | State files are <1 MB total. Counts against 5 GB GCS free allowance. |

---

## Repository Structure

```
pulse-infra/
├── bootstrap/
│   └── create_state_bucket.sh     # one-time: creates GCS bucket for .tfstate
├── environments/
│   └── prod/
│       ├── backend.tf             # GCS remote state config
│       ├── main.tf                # provider declaration + all module calls
│       ├── variables.tf           # input variable declarations
│       ├── outputs.tf             # surface key resource IDs
│       └── terraform.tfvars       # actual values (project ID, region, etc.)
├── modules/
│   ├── pubsub/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── bigquery/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── firestore/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── iam/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore
└── README.md
```

---

## Module Designs

### `modules/pubsub/`

**Resources:**
- `google_pubsub_topic.pulse_events` — name: `pulse-events`, message retention: 7 days
- `google_pubsub_subscription.pulse_events_sub` — name: `pulse-events-sub`, pull type, ack deadline: 60s, expiry policy: never

**Variables:** `project_id`, `topic_name`, `subscription_name`, `ack_deadline_seconds`

**Outputs:** `topic_id`, `topic_name`, `subscription_id`, `subscription_name`

---

### `modules/bigquery/`

**Resources:**
- `google_bigquery_dataset.pulse_raw` — dataset ID: `pulse_raw`, location: `US`, no default table expiry
- `google_bigquery_table.events` — table ID: `events`, schema below

**Schema for `events` table:**
```json
[
  {"name": "event_type",  "type": "STRING",    "mode": "NULLABLE"},
  {"name": "user_id",     "type": "STRING",    "mode": "NULLABLE"},
  {"name": "ingested_at", "type": "TIMESTAMP", "mode": "NULLABLE"},
  {"name": "session_id",  "type": "STRING",    "mode": "NULLABLE"},
  {"name": "properties",  "type": "JSON",      "mode": "NULLABLE"}
]
```

**Locals:** assembles `table_reference` string (`project.dataset.table`)

**Lifecycle:** `prevent_destroy = true` on the dataset

**Variables:** `project_id`, `dataset_id`, `table_id`, `location`

**Outputs:** `dataset_id`, `table_id`, `table_reference`

---

### `modules/firestore/`

**Resources:**
- `google_firestore_database.default` — name: `(default)`, type: `FIRESTORE_NATIVE`, location: `nam5` (US multi-region)

**Variables:** `project_id`, `location_id`

**Outputs:** `database_name`

---

### `modules/storage/`

**Resources:**
- `google_storage_bucket.reports` — name: `pulse-analytics-reports`, location: `US`, uniform bucket-level access: true, versioning: off, `force_destroy = true`

**Variables:** `project_id`, `bucket_name`, `location`

**Outputs:** `bucket_name`, `bucket_url`

---

### `modules/iam/`

**Resources:**
- `google_service_account.pulse_runner` — account ID: `pulse-runner`, display name: `Pulse Runtime SA`
- 5× `google_*_iam_member` bindings via `for_each` where applicable

**IAM Bindings:**

| Role | Resource type | Scope |
|---|---|---|
| `roles/pubsub.publisher` | `google_pubsub_topic_iam_member` | topic only |
| `roles/pubsub.subscriber` | `google_pubsub_subscription_iam_member` | subscription only |
| `roles/bigquery.dataEditor` | `google_bigquery_dataset_iam_member` | dataset only |
| `roles/datastore.user` | `google_project_iam_member` | project (Firestore Native requires this) |
| `roles/storage.objectAdmin` | `google_storage_bucket_iam_member` | bucket only |

**`depends_on`:** all bindings depend on `google_service_account.pulse_runner`

**Variables:** `project_id`, `service_account_id`, `topic_id`, `subscription_id`, `dataset_id`, `bucket_name`

**Outputs:** `service_account_email`, `service_account_id`

---

## Scanner Pattern Coverage

| Pattern | Location |
|---|---|
| `resource` blocks with explicit `project` | all modules |
| `variable` → `output` → input to another module | pubsub/bigquery/storage → iam |
| `data "google_project"` source | environments/prod/main.tf |
| `locals {}` block | modules/bigquery/main.tf |
| `depends_on` | modules/iam/main.tf |
| `lifecycle { prevent_destroy = true }` | modules/bigquery/main.tf |
| `for_each` over IAM role map | modules/iam/main.tf |
| GCS remote backend | environments/prod/backend.tf |
| `terraform.tfvars` with real values | environments/prod/ |

---

## Module Wiring (environments/prod/main.tf)

```
data "google_project" "current" {}

module "pubsub"    → outputs: topic_id, subscription_id
module "bigquery"  → outputs: dataset_id, table_reference
module "firestore" → (no outputs consumed by iam)
module "storage"   → outputs: bucket_name
module "iam"       ← consumes: topic_id, subscription_id, dataset_id, bucket_name
```

---

## Deployment Workflow

```bash
# One-time bootstrap
bash bootstrap/create_state_bucket.sh

# Standard workflow
cd environments/prod
terraform init
terraform plan
terraform apply
```

---

## GitHub Repository

- **Repo name:** `pulse-infra`
- **GitHub:** `ofirzip/pulse-infra`
- **Local:** `/Users/ofirz/dev/pulse-infra`
