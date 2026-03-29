# --- Staging tables ---

resource "google_bigquery_table" "staging_marriage_rate" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "marriage_rate"
  deletion_protection = false

  schema = jsonencode([
    { name = "country",       type = "STRING",  mode = "NULLABLE" },
    { name = "year",          type = "INTEGER", mode = "NULLABLE" },
    { name = "marriage_rate", type = "FLOAT",   mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "staging_divorce_rate" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "divorce_rate"
  deletion_protection = false

  schema = jsonencode([
    { name = "country",      type = "STRING",  mode = "NULLABLE" },
    { name = "year",         type = "INTEGER", mode = "NULLABLE" },
    { name = "divorce_rate", type = "FLOAT",   mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "staging_age_at_marriage" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "age_at_marriage"
  deletion_protection = false

  schema = jsonencode([
    { name = "country",           type = "STRING",  mode = "NULLABLE" },
    { name = "year",              type = "INTEGER", mode = "NULLABLE" },
    { name = "age_at_marriage_f", type = "FLOAT",   mode = "NULLABLE" },
    { name = "age_at_marriage_m", type = "FLOAT",   mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "staging_gender_pay_gap" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "gender_pay_gap"
  deletion_protection = false

  schema = jsonencode([
    { name = "country",        type = "STRING",  mode = "NULLABLE" },
    { name = "year",           type = "INTEGER", mode = "NULLABLE" },
    { name = "gender_pay_gap", type = "FLOAT",   mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "staging_hours_worked" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "hours_worked"
  deletion_protection = false

  schema = jsonencode([
    { name = "country",            type = "STRING",  mode = "NULLABLE" },
    { name = "year",               type = "INTEGER", mode = "NULLABLE" },
    { name = "hours_worked_m",     type = "FLOAT",   mode = "NULLABLE" },
    { name = "hours_worked_f",     type = "FLOAT",   mode = "NULLABLE" },
    { name = "hours_worked_delta", type = "FLOAT",   mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "staging_accidents" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "accidents"
  deletion_protection = false


  schema = jsonencode([
    { name = "country",     type = "STRING",  mode = "NULLABLE" },
    { name = "year",        type = "INTEGER", mode = "NULLABLE" },
    { name = "accidents_m", type = "FLOAT", mode = "NULLABLE" },
    { name = "accidents_f", type = "FLOAT", mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "staging_employed" {
  dataset_id          = google_bigquery_dataset.staging.dataset_id
  table_id            = "employed"
  deletion_protection = false

  schema = jsonencode([
    { name = "country",    type = "STRING",  mode = "NULLABLE" },
    { name = "year",       type = "INTEGER", mode = "NULLABLE" },
    { name = "employed_m", type = "FLOAT",   mode = "NULLABLE" },
    { name = "employed_f", type = "FLOAT",   mode = "NULLABLE" },
  ])
}

# --- Analytics tables ---

resource "google_bigquery_table" "analytics_relationships" {
  dataset_id          = google_bigquery_dataset.analytics.dataset_id
  table_id            = "relationships"
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "year_date"
  }

  clustering = ["country"]

  schema = jsonencode([
    { name = "year_date",         type = "DATE",    mode = "NULLABLE" },
    { name = "country",           type = "STRING",  mode = "NULLABLE" },
    { name = "year",              type = "INTEGER", mode = "NULLABLE" },
    { name = "marriage_rate",     type = "FLOAT",   mode = "NULLABLE" },
    { name = "divorce_rate",      type = "FLOAT",   mode = "NULLABLE" },
    { name = "age_at_marriage_f", type = "FLOAT",   mode = "NULLABLE" },
    { name = "age_at_marriage_m", type = "FLOAT",   mode = "NULLABLE" },
    { name = "gender_pay_gap",    type = "FLOAT",   mode = "NULLABLE" },
  ])
}

resource "google_bigquery_table" "analytics_gender_gap" {
  dataset_id          = google_bigquery_dataset.analytics.dataset_id
  table_id            = "gender_gap"
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "year_date"
  }

  clustering = ["country"]

  schema = jsonencode([
    { name = "year_date",           type = "DATE",    mode = "NULLABLE" },
    { name = "country",             type = "STRING",  mode = "NULLABLE" },
    { name = "year",                type = "INTEGER", mode = "NULLABLE" },
    { name = "hours_worked_m",      type = "FLOAT",   mode = "NULLABLE" },
    { name = "hours_worked_f",      type = "FLOAT",   mode = "NULLABLE" },
    { name = "hours_worked_delta",  type = "FLOAT",   mode = "NULLABLE" },
    { name = "gender_pay_gap",      type = "FLOAT",   mode = "NULLABLE" },
    { name = "accidents_m",         type = "FLOAT", mode = "NULLABLE" },
    { name = "accidents_f",         type = "FLOAT", mode = "NULLABLE" },
    { name = "employed_m",          type = "FLOAT",   mode = "NULLABLE" },
    { name = "employed_f",          type = "FLOAT",   mode = "NULLABLE" },
  ])
}
