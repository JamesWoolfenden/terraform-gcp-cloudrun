# holden:ignore:HLD_TF_004
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.30.0"
    }
  }

  required_version = ">= 1.9.0" # cross-variable validation (var.worker_pool_image / var.legacy_service_image referenced from the service account validations) requires 1.9+
}
