# The v1 API is legacy: google_cloud_run_v2_service above is the resource to use.
# This block exists for callers still migrating a v1 service and is off by default.
resource "google_cloud_run_service" "legacy" {
  count = var.legacy_service_image == "" ? 0 : 1

  name     = "${google_cloud_run_v2_service.default.name}-legacy"
  location = google_cloud_run_v2_service.default.location

  template {
    spec {
      service_account_name = var.legacy_service_account

      containers {
        image = var.legacy_service_image
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
