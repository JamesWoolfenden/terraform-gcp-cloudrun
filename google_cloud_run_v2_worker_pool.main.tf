resource "google_cloud_run_v2_worker_pool" "main" {
  count = var.worker_pool_image == "" ? 0 : 1

  name     = "${google_cloud_run_v2_service.default.name}-workers"
  location = google_cloud_run_v2_service.default.location

  template {
    service_account = var.worker_pool_service_account

    containers {
      image = var.worker_pool_image
    }
  }
}
