terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "tf-state-zoomcamp"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_storage_bucket" "data_lake" {
  name          = var.bucket
  location      = var.region
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_bigquery_dataset" "load" {
  dataset_id                 = "load"
  location                   = var.region
  delete_contents_on_destroy = true # this is ok oly for development, in production you should remove this line to avoid data loss
}

resource "google_bigquery_dataset" "staging" {
  dataset_id                 = "staging"
  location                   = var.region
  delete_contents_on_destroy = true # this is ok oly for development, in production you should remove this line to avoid data loss
}


resource "google_bigquery_dataset" "analytics" {
  dataset_id                 = "analytics"
  location                   = var.region
  delete_contents_on_destroy = true # this is ok oly for development, in production you should remove this line to avoid data loss
}

