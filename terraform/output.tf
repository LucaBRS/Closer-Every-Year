output "bucket_name" {
  description = "GCS bucket name"
  value       = google_storage_bucket.data_lake.name
}

output "bigquery_datasets" {
  description = "BigQuery dataset IDs"
  value = [
    google_bigquery_dataset.load.dataset_id,
    google_bigquery_dataset.staging.dataset_id,
    google_bigquery_dataset.analytics.dataset_id,
  ]
}
