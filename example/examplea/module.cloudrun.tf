# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
resource "google_service_account" "cloudrun" {
  project      = var.project
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run service account"
}

resource "google_kms_key_ring" "cloudrun" {
  project  = var.project
  name     = "cloudrun-keyring"
  location = "us-central1"
}

resource "google_kms_crypto_key" "cloudrun" {
  name            = "cloudrun-key"
  key_ring        = google_kms_key_ring.cloudrun.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

data "google_vpc_access_connector" "cloudrun" {
  project = var.project
  name    = "cloudrun-connector"
  region  = "us-central1"
}

# holden:ignore:HLD_TF_026
# holden:ignore:HLD_TF_078
module "cloudrun" {
  source          = "../../"
  project         = var.project
  service_account = google_service_account.cloudrun.email
  encryption_key  = google_kms_crypto_key.cloudrun.id
  vpc_connector   = data.google_vpc_access_connector.cloudrun.id
  containers = [
    {
      name           = "backend"
      container_port = 8080
      image          = "nginx:1.27.4"
      depends_on     = null
      env = {
        name = "frontend"
      }
      volume_mounts = {
        name       = "empty-dir-volume"
        mount_path = "/mnt"
      }
    }
  ]
  volumes = [
    {
      name      = "empty-dir-volume"
      empty_dir = { medium = "MEMORY" }
    }
  ]
  service = {
    name         = "cloudrun-service"
    location     = "us-central1"
    launch_stage = "BETA"
    ingress      = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  }
}
