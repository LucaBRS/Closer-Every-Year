# Pipeline Strategy

## Overview

The project runs two parallel pipelines:
- **`local-pipeline/`** — local development using DuckDB
- **`gcp-pipeline/`** — production using Google Cloud Platform (GCS + BigQuery)

Both follow the same 4-layer architecture: **ingestion → load → staging → analytics**

---

## Layer Strategies

### Ingestion (`ingestion.*`)

- **Type**: `python` (script, no connection/materialization)
- **What it does**: Downloads raw data from the Eurostat API and saves it as Parquet files
  - Local: saves to `/workspace/data/datalake/`
  - GCP: saves to GCS bucket (`gs://<bucket>/`)
- **Idempotency**: full overwrite on each run (Parquet file is replaced)

### Load (`load.*`)

- **Type**: `python` with `connection` + `materialization: type: table`
- **What it does**: Reads raw Parquet, transforms wide→long format using `pandas.melt()`, returns a DataFrame to Bruin for ingestion into the database
- **Strategy**: default (`type: table`) — Bruin/dlt performs a full replace on each run
- **Why not merge**: dlt (used internally by Bruin for Python assets) has a bug where it raises a terminal error on `create_dataset()` if the dataset already exists, making `strategy: merge` unreliable for Python assets
- **Why melt() here**: BigQuery does not support dynamic column pivoting (`UNPIVOT COLUMNS(*)`), so the wide→long transformation must happen in Python before the data reaches SQL

### Staging (`staging.*`)

- **Type**: `bq.sql` (BigQuery SQL)
- **Strategy**: `merge` on `(country, year)` as primary key
- **What it does**: Applies final transformations — wide→long pivot for M/F columns (`age_at_marriage`, `hours_worked`, `accidents`, `employed`), passthrough for single-value datasets (`gender_pay_gap`)
- **Why merge**: SQL assets use BigQuery's native `MERGE INTO` statement — no dlt involved, no 409 bug. Running the pipeline multiple times will update existing rows rather than duplicating them
- **Prerequisite**: tables must exist before the first merge run. **Terraform creates all staging tables** via `tables.tf` — run `terraform apply` before the first pipeline run

### Analytics (`analytics.*`)

Two final tables, both `bq.sql` type:

**`analytics.relationships`** — marriage, divorce, age at marriage, gender pay gap
**`analytics.gender_gap`** — hours worked, accidents, employment rate, gender pay gap (all M/F split)

Both share the same configuration:
- **Strategy**: `merge` on `(country, year)` as primary key
- **Partition**: `year_date` (DATE column computed as `DATE(year, 12, 31)`) — enables time-based partition pruning in BigQuery
- **Cluster**: `country` — optimises queries that filter or group by country
- **Why DATE for partition**: BigQuery time-based partitioning requires a DATE or TIMESTAMP column; integer year columns require RANGE partitioning (less ergonomic for dashboard tools)

---

## Materialization Strategy Summary

| Layer | Asset type | Strategy | Primary key | Notes |
|-------|-----------|----------|-------------|-------|
| ingestion | python (script) | — | — | Overwrites Parquet on GCS/local |
| load | python + dlt | table (full replace) | — | dlt merge bug workaround |
| staging | bq.sql | merge | (country, year) | BQ native MERGE, idempotent |
| analytics.relationships | bq.sql | merge + partition + cluster | (country, year) | marriage, divorce, pay gap |
| analytics.gender_gap | bq.sql | merge + partition + cluster | (country, year) | hours worked, accidents, employment |

---

## Infrastructure (Terraform)

Terraform manages:
- **GCS bucket**: name set via `TF_VAR_bucket` — stores raw Parquet files, with a 30-day lifecycle rule
- **BigQuery datasets**: `load`, `staging`, `analytics`
- **BigQuery tables**: all staging and analytics tables with explicit schemas, defined in `tables.tf`

Terraform is the **single source of truth for table schemas**. `lifecycle { ignore_changes = [schema] }` is intentionally absent — if a schema changes, drop the table in BigQuery and run `terraform apply` to recreate it with the correct schema, then re-run the pipeline to repopulate.

---

## CI/CD (GitHub Actions)

Two workflows in `.github/workflows/`:

### `pipeline.yml` — Scheduled pipeline

Triggers automatically on **1 January and 1 July** (Eurostat data updates on a ~yearly cadence) plus manual `workflow_dispatch`.

Sequence:
1. Checkout repo
2. Create `.env` from GitHub Secrets/Variables
3. Create `.bruin.yml` from the `BRUIN_YML` secret
4. `sudo chmod -R 777 .git .gitignore` — fixes Docker volume mount permissions on the Actions runner
5. `docker compose up -d --build` — starts the Bruin container
6. `bruin run --environment cloud gcp-pipeline` — runs the full pipeline
7. `docker compose down` — always tears down, even on failure

**Secrets handling**: Both `GOOGLE_CREDENTIALS` and `BRUIN_YML` are passed via `env:` in the workflow step — not interpolated directly into the shell command. This prevents bash from stripping JSON quotes and expanding `${...}` variables inside the secret values. The credentials JSON can be stored exactly as downloaded from GCP, no minification needed.

### `terraform.yml` — Manual infrastructure apply

Manual-only (`workflow_dispatch`). Used when infrastructure needs to be created or updated — schema changes, new tables, first-time setup.

Sequence: checkout → create `.env` → `docker compose up -d terraform` → `terraform init` → `terraform apply -auto-approve` → tear down.

### Required GitHub configuration

| Name | Type | Description |
|---|---|---|
| `GOOGLE_CREDENTIALS` | Secret | GCP service account JSON (content of the `.json` file) |
| `BRUIN_YML` | Secret | Full content of `.bruin.yml` |
| `GCP_PROJECT_ID` | Variable | GCP project ID |
| `GCS_BUCKET` | Variable | GCS bucket path (e.g. `gs://my-bucket`) |
| `TF_VAR_bucket` | Variable | GCS bucket name without `gs://` prefix (e.g. `my-bucket`) |
| `TF_VAR_region` | Variable | GCP region for Terraform (e.g. `EU`) |

---

## Known Issues / Design Decisions

- **dlt 409 bug**: dlt does not pass `exists_ok=True` when calling `create_dataset()` on BigQuery. If multiple load assets run in parallel, the second asset to start fails because the dataset was already created by the first. Workaround: `load.*` assets use `type: table` (no explicit strategy), relying on the default full-replace behaviour.
- **STRUCT schema issue**: `load_table_from_dataframe()` in some configurations wraps all columns in a STRUCT. Resolved by using a GCS intermediate Parquet file with `load_table_from_uri()` instead.
- **BigQuery staging alias**: staging SQL queries that reference a table with the same name as a column require a table alias to avoid ambiguity in `CASE WHEN` expressions (e.g. `FROM load.gender_pay_gap AS t`).
