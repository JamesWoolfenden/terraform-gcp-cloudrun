# The v1 API is legacy: google_cloud_run_v2_service above is the resource to use.
# This block exists for callers still migrating a v1 service and is off by default.
resource "google_cloud_run_service" "legacy" {
  count = var.legacy_service_image == "" ? 0 : 1

  name     = "${google_cloud_run_v2_service.default.name}-legacy"
  location = google_cloud_run_v2_service.default.location
  project  = var.project

  # v1 has no ingress or binary_authorization arguments; these annotations
  # carry the same settings the v2 service uses, so the migration copy is
  # not more exposed than the service it shadows.
  metadata {
    annotations = {
      "run.googleapis.com/ingress"              = local.legacy_ingress[var.service.ingress]
      "run.googleapis.com/binary-authorization" = "default"
    }
  }

  template {
    metadata {
      annotations = var.encryption_key == null ? {} : {
        "run.googleapis.com/encryption-key" = var.encryption_key
      }
    }

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

  depends_on = [google_kms_crypto_key_iam_member.cloud_run_service_agent]
}
