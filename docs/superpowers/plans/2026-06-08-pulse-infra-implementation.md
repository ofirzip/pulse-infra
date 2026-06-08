# Pulse Infra Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provision all GCP resources for `pulse-demo` via Terraform IaC in a structured repo that also serves as a realistic VAST IaC scanner target.

**Architecture:** `environments/prod/` is the Terraform entry point, calling five child modules (`pubsub`, `bigquery`, `firestore`, `storage`, `iam`). The `iam` module consumes outputs from the other four. A one-time bootstrap script creates the GCS remote state bucket before `terraform init`.

**Tech Stack:** Terraform ≥ 1.5, `hashicorp/google` provider ~5.0, GCS remote backend, GCP project `pulse-analytics-prod-498809`.

---

## File Structure

```
pulse-infra/
├── bootstrap/
│   └── create_state_bucket.sh
├── environments/
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── variables.tf
│       └── terraform.tfvars
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

### Task 1: Repository skeleton — .gitignore and bootstrap script

**Files:**
- Create: `.gitignore`
- Create: `bootstrap/create_state_bucket.sh`

- [ ] **Step 1: Write .gitignore**

Create `/Users/ofirz/dev/pulse-infra/.gitignore`:

```
# Terraform
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.*
*.tfplan
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Secrets
*.tfvars.json
secrets/

# OS
.DS_Store
```

- [ ] **Step 2: Write bootstrap/create_state_bucket.sh**

Create `/Users/ofirz/dev/pulse-infra/bootstrap/create_state_bucket.sh`:

```bash
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
```

- [ ] **Step 3: Make the script executable and run it**

```bash
chmod +x /Users/ofirz/dev/pulse-infra/bootstrap/create_state_bucket.sh
bash /Users/ofirz/dev/pulse-infra/bootstrap/create_state_bucket.sh
```

Expected output:
```
Creating Terraform state bucket: gs://pulse-analytics-tfstate
Done. Bucket gs://pulse-analytics-tfstate is ready.
```

- [ ] **Step 4: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add .gitignore bootstrap/create_state_bucket.sh
git commit -m "feat: add .gitignore and bootstrap state bucket script"
```

---

### Task 2: environments/prod skeleton

**Files:**
- Create: `environments/prod/backend.tf`
- Create: `environments/prod/variables.tf`
- Create: `environments/prod/terraform.tfvars`
- Create: `environments/prod/main.tf` (stub — provider + data source only)
- Create: `environments/prod/outputs.tf` (stub — empty)

- [ ] **Step 1: Write backend.tf**

Create `/Users/ofirz/dev/pulse-infra/environments/prod/backend.tf`:

```hcl
terraform {
  backend "gcs" {
    bucket = "pulse-analytics-tfstate"
    prefix = "terraform/prod"
  }
}
```

- [ ] **Step 2: Write variables.tf**

Create `/Users/ofirz/dev/pulse-infra/environments/prod/variables.tf`:

```hcl
variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for resources"
  default     = "us-central1"
}

variable "topic_name" {
  type    = string
  default = "pulse-events"
}

variable "subscription_name" {
  type    = string
  default = "pulse-events-sub"
}

variable "bq_dataset_id" {
  type    = string
  default = "pulse_raw"
}

variable "bq_table_id" {
  type    = string
  default = "events"
}

variable "bucket_name" {
  type    = string
  default = "pulse-analytics-reports"
}

variable "firestore_location" {
  type    = string
  default = "nam5"
}
```

- [ ] **Step 3: Write terraform.tfvars**

Create `/Users/ofirz/dev/pulse-infra/environments/prod/terraform.tfvars`:

```hcl
project_id         = "pulse-analytics-prod-498809"
region             = "us-central1"
topic_name         = "pulse-events"
subscription_name  = "pulse-events-sub"
bq_dataset_id      = "pulse_raw"
bq_table_id        = "events"
bucket_name        = "pulse-analytics-reports"
firestore_location = "nam5"
```

- [ ] **Step 4: Write main.tf stub**

Create `/Users/ofirz/dev/pulse-infra/environments/prod/main.tf`:

```hcl
terraform {
  required_version = ">= 1.5"
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
```

- [ ] **Step 5: Write outputs.tf stub**

Create `/Users/ofirz/dev/pulse-infra/environments/prod/outputs.tf`:

```hcl
# Outputs added in Task 8 after all modules are wired up
```

- [ ] **Step 6: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add environments/
git commit -m "feat: add environments/prod skeleton with backend and variables"
```

---

### Task 3: terraform init

**Files:** none created

- [ ] **Step 1: Run terraform init**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform init
```

Expected output ends with:
```
Terraform has been successfully initialized!
```

If you see `Error: Failed to get existing workspaces`, the state bucket was not created. Go back and run Task 1 Step 3.

- [ ] **Step 2: Verify provider lock file was created**

```bash
ls /Users/ofirz/dev/pulse-infra/environments/prod/.terraform.lock.hcl
```

Expected: file exists.

- [ ] **Step 3: Commit the lock file**

```bash
cd /Users/ofirz/dev/pulse-infra
git add environments/prod/.terraform.lock.hcl
git commit -m "chore: add terraform provider lock file"
```

---

### Task 4: pubsub module

**Files:**
- Create: `modules/pubsub/main.tf`
- Create: `modules/pubsub/variables.tf`
- Create: `modules/pubsub/outputs.tf`
- Modify: `environments/prod/main.tf` (add module call)

- [ ] **Step 1: Write modules/pubsub/variables.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/pubsub/variables.tf`:

```hcl
variable "project_id" {
  type = string
}

variable "topic_name" {
  type    = string
  default = "pulse-events"
}

variable "subscription_name" {
  type    = string
  default = "pulse-events-sub"
}

variable "ack_deadline_seconds" {
  type    = number
  default = 60
}
```

- [ ] **Step 2: Write modules/pubsub/main.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/pubsub/main.tf`:

```hcl
resource "google_pubsub_topic" "pulse_events" {
  project = var.project_id
  name    = var.topic_name

  message_retention_duration = "604800s" # 7 days
}

resource "google_pubsub_subscription" "pulse_events_sub" {
  project = var.project_id
  name    = var.subscription_name
  topic   = google_pubsub_topic.pulse_events.id

  ack_deadline_seconds = var.ack_deadline_seconds

  expiration_policy {
    ttl = "" # never expires
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }
}
```

- [ ] **Step 3: Write modules/pubsub/outputs.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/pubsub/outputs.tf`:

```hcl
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
```

- [ ] **Step 4: Add pubsub module call to environments/prod/main.tf**

Append to `/Users/ofirz/dev/pulse-infra/environments/prod/main.tf`:

```hcl

module "pubsub" {
  source = "../../modules/pubsub"

  project_id        = var.project_id
  topic_name        = var.topic_name
  subscription_name = var.subscription_name
}
```

- [ ] **Step 5: Validate**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform init -upgrade
terraform validate
```

Expected:
```
Success! The configuration is valid.
```

- [ ] **Step 6: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add modules/pubsub/ environments/prod/main.tf
git commit -m "feat: add pubsub module (topic + subscription)"
```

---

### Task 5: bigquery module

**Files:**
- Create: `modules/bigquery/main.tf`
- Create: `modules/bigquery/variables.tf`
- Create: `modules/bigquery/outputs.tf`
- Modify: `environments/prod/main.tf` (add module call)

- [ ] **Step 1: Write modules/bigquery/variables.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/bigquery/variables.tf`:

```hcl
variable "project_id" {
  type = string
}

variable "dataset_id" {
  type    = string
  default = "pulse_raw"
}

variable "table_id" {
  type    = string
  default = "events"
}

variable "location" {
  type    = string
  default = "US"
}
```

- [ ] **Step 2: Write modules/bigquery/main.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/bigquery/main.tf`:

```hcl
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
    { name = "event_type",  type = "STRING",    mode = "NULLABLE" },
    { name = "user_id",     type = "STRING",    mode = "NULLABLE" },
    { name = "ingested_at", type = "TIMESTAMP", mode = "NULLABLE" },
    { name = "session_id",  type = "STRING",    mode = "NULLABLE" },
    { name = "properties",  type = "JSON",      mode = "NULLABLE" }
  ])
}
```

- [ ] **Step 3: Write modules/bigquery/outputs.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/bigquery/outputs.tf`:

```hcl
output "dataset_id" {
  value = google_bigquery_dataset.pulse_raw.dataset_id
}

output "table_id" {
  value = google_bigquery_table.events.table_id
}

output "table_reference" {
  value = local.table_reference
}
```

- [ ] **Step 4: Add bigquery module call to environments/prod/main.tf**

Append to `/Users/ofirz/dev/pulse-infra/environments/prod/main.tf`:

```hcl

module "bigquery" {
  source = "../../modules/bigquery"

  project_id = var.project_id
  dataset_id = var.bq_dataset_id
  table_id   = var.bq_table_id
  location   = "US"
}
```

- [ ] **Step 5: Validate**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform validate
```

Expected:
```
Success! The configuration is valid.
```

- [ ] **Step 6: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add modules/bigquery/ environments/prod/main.tf
git commit -m "feat: add bigquery module (dataset + events table)"
```

---

### Task 6: firestore module

**Files:**
- Create: `modules/firestore/main.tf`
- Create: `modules/firestore/variables.tf`
- Create: `modules/firestore/outputs.tf`
- Modify: `environments/prod/main.tf` (add module call)

- [ ] **Step 1: Write modules/firestore/variables.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/firestore/variables.tf`:

```hcl
variable "project_id" {
  type = string
}

variable "location_id" {
  type    = string
  default = "nam5"
}
```

- [ ] **Step 2: Write modules/firestore/main.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/firestore/main.tf`:

```hcl
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.location_id
  type        = "FIRESTORE_NATIVE"
}
```

- [ ] **Step 3: Write modules/firestore/outputs.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/firestore/outputs.tf`:

```hcl
output "database_name" {
  value = google_firestore_database.default.name
}
```

- [ ] **Step 4: Add firestore module call to environments/prod/main.tf**

Append to `/Users/ofirz/dev/pulse-infra/environments/prod/main.tf`:

```hcl

module "firestore" {
  source = "../../modules/firestore"

  project_id  = var.project_id
  location_id = var.firestore_location
}
```

- [ ] **Step 5: Validate**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform validate
```

Expected:
```
Success! The configuration is valid.
```

- [ ] **Step 6: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add modules/firestore/ environments/prod/main.tf
git commit -m "feat: add firestore module (native mode database)"
```

---

### Task 7: storage module

**Files:**
- Create: `modules/storage/main.tf`
- Create: `modules/storage/variables.tf`
- Create: `modules/storage/outputs.tf`
- Modify: `environments/prod/main.tf` (add module call)

- [ ] **Step 1: Write modules/storage/variables.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/storage/variables.tf`:

```hcl
variable "project_id" {
  type = string
}

variable "bucket_name" {
  type    = string
  default = "pulse-analytics-reports"
}

variable "location" {
  type    = string
  default = "US"
}
```

- [ ] **Step 2: Write modules/storage/main.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/storage/main.tf`:

```hcl
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
```

- [ ] **Step 3: Write modules/storage/outputs.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/storage/outputs.tf`:

```hcl
output "bucket_name" {
  value = google_storage_bucket.reports.name
}

output "bucket_url" {
  value = google_storage_bucket.reports.url
}
```

- [ ] **Step 4: Add storage module call to environments/prod/main.tf**

Append to `/Users/ofirz/dev/pulse-infra/environments/prod/main.tf`:

```hcl

module "storage" {
  source = "../../modules/storage"

  project_id  = var.project_id
  bucket_name = var.bucket_name
  location    = "US"
}
```

- [ ] **Step 5: Validate**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform validate
```

Expected:
```
Success! The configuration is valid.
```

- [ ] **Step 6: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add modules/storage/ environments/prod/main.tf
git commit -m "feat: add storage module (reports bucket)"
```

---

### Task 8: iam module + wire outputs

**Files:**
- Create: `modules/iam/main.tf`
- Create: `modules/iam/variables.tf`
- Create: `modules/iam/outputs.tf`
- Modify: `environments/prod/main.tf` (add iam module call)
- Modify: `environments/prod/outputs.tf` (add all module outputs)

- [ ] **Step 1: Write modules/iam/variables.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/iam/variables.tf`:

```hcl
variable "project_id" {
  type = string
}

variable "service_account_id" {
  type    = string
  default = "pulse-runner"
}

variable "topic_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "dataset_id" {
  type = string
}

variable "bucket_name" {
  type = string
}
```

- [ ] **Step 2: Write modules/iam/main.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/iam/main.tf`:

```hcl
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
```

- [ ] **Step 3: Write modules/iam/outputs.tf**

Create `/Users/ofirz/dev/pulse-infra/modules/iam/outputs.tf`:

```hcl
output "service_account_email" {
  value = google_service_account.pulse_runner.email
}

output "service_account_id" {
  value = google_service_account.pulse_runner.id
}
```

- [ ] **Step 4: Add iam module call to environments/prod/main.tf**

Append to `/Users/ofirz/dev/pulse-infra/environments/prod/main.tf`:

```hcl

module "iam" {
  source = "../../modules/iam"

  project_id        = var.project_id
  topic_id          = module.pubsub.topic_id
  subscription_id   = module.pubsub.subscription_id
  dataset_id        = module.bigquery.dataset_id
  bucket_name       = module.storage.bucket_name
}
```

- [ ] **Step 5: Replace the stub in environments/prod/outputs.tf**

Replace the contents of `/Users/ofirz/dev/pulse-infra/environments/prod/outputs.tf` with:

```hcl
output "pubsub_topic_id" {
  value = module.pubsub.topic_id
}

output "pubsub_subscription_id" {
  value = module.pubsub.subscription_id
}

output "bigquery_dataset_id" {
  value = module.bigquery.dataset_id
}

output "bigquery_table_reference" {
  value = module.bigquery.table_reference
}

output "firestore_database_name" {
  value = module.firestore.database_name
}

output "storage_bucket_name" {
  value = module.storage.bucket_name
}

output "storage_bucket_url" {
  value = module.storage.bucket_url
}

output "service_account_email" {
  value = module.iam.service_account_email
}
```

- [ ] **Step 6: Validate**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform validate
```

Expected:
```
Success! The configuration is valid.
```

- [ ] **Step 7: Commit**

```bash
cd /Users/ofirz/dev/pulse-infra
git add modules/iam/ environments/prod/main.tf environments/prod/outputs.tf
git commit -m "feat: add iam module (service account + least-privilege bindings)"
```

---

### Task 9: terraform plan — review what will be created

**Files:** none modified

- [ ] **Step 1: Run terraform plan**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform plan
```

Expected: plan shows **13 resources to add**, 0 to change, 0 to destroy:

```
+ google_bigquery_dataset.pulse_raw
+ google_bigquery_table.events
+ google_firestore_database.default
+ google_project_iam_member.project_roles["roles/bigquery.jobUser"]
+ google_project_iam_member.project_roles["roles/datastore.user"]
+ google_pubsub_subscription.pulse_events_sub
+ google_pubsub_subscription_iam_member.subscriber
+ google_pubsub_topic.pulse_events
+ google_pubsub_topic_iam_member.publisher
+ google_service_account.pulse_runner
+ google_bigquery_dataset_iam_member.bq_editor
+ google_storage_bucket.reports
+ google_storage_bucket_iam_member.object_admin
```

If the count differs, read the error and trace back to the affected module.

- [ ] **Step 2: Save the plan to a file for review**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform plan -out=tfplan.binary
terraform show -no-color tfplan.binary > /tmp/pulse-infra-plan.txt
cat /tmp/pulse-infra-plan.txt
```

Read through the output and verify:
- `google_bigquery_dataset.pulse_raw` has `location = "US"` and `lifecycle { prevent_destroy = true }`
- `google_firestore_database.default` has `type = "FIRESTORE_NATIVE"` and `location_id = "nam5"`
- `google_storage_bucket.reports` has `location = "US"` and `uniform_bucket_level_access = true`
- All IAM members reference `serviceAccount:pulse-runner@pulse-analytics-prod-498809.iam.gserviceaccount.com`

---

### Task 10: terraform apply — provision all resources

**Files:** none modified

- [ ] **Step 1: Apply the saved plan**

```bash
cd /Users/ofirz/dev/pulse-infra/environments/prod
terraform apply tfplan.binary
```

Expected output ends with:
```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:
bigquery_dataset_id      = "pulse_raw"
bigquery_table_reference = "pulse-analytics-prod-498809.pulse_raw.events"
firestore_database_name  = "(default)"
pubsub_subscription_id   = "projects/pulse-analytics-prod-498809/subscriptions/pulse-events-sub"
pubsub_topic_id          = "projects/pulse-analytics-prod-498809/topics/pulse-events"
service_account_email    = "pulse-runner@pulse-analytics-prod-498809.iam.gserviceaccount.com"
storage_bucket_name      = "pulse-analytics-reports"
storage_bucket_url       = "gs://pulse-analytics-reports"
```

- [ ] **Step 2: Verify resources in GCP Console or via gcloud**

```bash
~/google-cloud-sdk/bin/gcloud pubsub topics list --project=pulse-analytics-prod-498809
~/google-cloud-sdk/bin/gcloud pubsub subscriptions list --project=pulse-analytics-prod-498809
~/google-cloud-sdk/bin/gcloud storage buckets list --project=pulse-analytics-prod-498809
```

Each command should return the expected resource.

- [ ] **Step 3: Clean up plan file (not committed)**

```bash
rm /Users/ofirz/dev/pulse-infra/environments/prod/tfplan.binary
```

---

### Task 11: README and GitHub repo

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write README.md**

Create `/Users/ofirz/dev/pulse-infra/README.md`:

```markdown
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
```

- [ ] **Step 2: Commit README and verify git log**

```bash
cd /Users/ofirz/dev/pulse-infra
git add README.md
git commit -m "docs: add README with resource table and usage instructions"
git log --oneline
```

Expected log (6 commits):
```
<sha> docs: add README with resource table and usage instructions
<sha> feat: add iam module (service account + least-privilege bindings)
<sha> feat: add storage module (reports bucket)
<sha> feat: add firestore module (native mode database)
<sha> feat: add bigquery module (dataset + events table)
<sha> feat: add pubsub module (topic + subscription)
<sha> chore: add terraform provider lock file
<sha> feat: add environments/prod skeleton with backend and variables
<sha> feat: add .gitignore and bootstrap state bucket script
<sha> feat: add design spec for pulse-infra
```

- [ ] **Step 3: Create GitHub repo and push**

```bash
cd /Users/ofirz/dev/pulse-infra
gh repo create ofirzip/pulse-infra --public --source=. --remote=origin --push
```

Expected:
```
✓ Created repository ofirzip/pulse-infra on GitHub
✓ Pushed commits to https://github.com/ofirzip/pulse-infra
```

- [ ] **Step 4: Verify on GitHub**

```bash
gh repo view ofirzip/pulse-infra --web
```

This opens the repo in the browser. Confirm the file tree and README are visible.
```
