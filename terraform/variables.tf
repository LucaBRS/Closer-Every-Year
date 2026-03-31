variable "project_id" {
  description = "GCP Project ID — set via TF_VAR_project_id in .env"
  type        = string
}

variable "region" {
  description = "GCP Region — set via TF_VAR_region in .env"
  type        = string
  default     = "EU"
}

variable "bucket" {
  description = "GCS bucket name (without gs:// prefix) — set via TF_VAR_bucket in .env"
  type        = string
}

variable "billing_account_id" {
  description = "GCP Billing Account ID — set via TF_VAR_billing_account_id in .env"
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget limit in EUR before alert triggers"
  type        = number
  default     = 5
}

