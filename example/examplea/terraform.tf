terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.30.0"
    }
  }

  # Require Terraform 1.5 or newer
  required_version = ">= 1.5"
}
