resource "google_cloud_run_v2_worker_pool" "main" {
  count = var.worker_pool_image == "" ? 0 : 1

  name     = "${google_cloud_run_v2_service.default.name}-workers"
  location = google_cloud_run_v2_service.default.location
  project  = var.project

  # Same controls the main service enforces: Binary Authorization on the
  # deployed image and CMEK when the caller supplies a key.
  binary_authorization {
    use_default = true
  }

  template {
    service_account = var.worker_pool_service_account
    encryption_key  = var.encryption_key

    containers {
      image = var.worker_pool_image
    }
  }

  depends_on = [google_kms_crypto_key_iam_member.cloud_run_service_agent]
}
