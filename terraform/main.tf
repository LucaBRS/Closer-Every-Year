terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
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

resource "google_billing_budget" "monthly_cap" {
  provider        = google-beta
  billing_account = var.billing_account_id
  display_name    = "closer-every-year-budget"

  budget_filter {
    projects = ["projects/${var.project_id}"]
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = "EUR"
      units         = tostring(var.budget_amount)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
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

