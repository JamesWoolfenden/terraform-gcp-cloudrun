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


# holden:ignore:HLD_GCP_093: just enough network to drive the module
# holden:ignore:HLD_GCP_094: just enough network to drive the module
# holden:ignore:HLD_GCP_303: just enough network to drive the module
resource "google_compute_network" "cloudrun" {
  project                 = var.project
  name                    = "cloudrun-connector-net"
  auto_create_subnetworks = false
}

resource "google_vpc_access_connector" "cloudrun" {
  project       = var.project
  name          = "cloudrun-connector"
  region        = "us-central1"
  network       = google_compute_network.cloudrun.name
  ip_cidr_range = "10.8.0.0/28"
  min_instances = 2
  max_instances = 3
}

locals {
  # Built from known names, not google_kms_crypto_key.cloudrun.id, so the
  # module's count on encryption_key is decidable at plan time.
  cloudrun_key_id = "projects/${var.project}/locations/us-central1/keyRings/cloudrun-keyring/cryptoKeys/cloudrun-key"
}

# holden:ignore:HLD_TF_026
# holden:ignore:HLD_TF_078
module "cloudrun" {
  source          = "../../"
  project         = var.project
  service_account = google_service_account.cloudrun.email
  encryption_key  = local.cloudrun_key_id
  vpc_connector   = google_vpc_access_connector.cloudrun.id
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

  depends_on = [google_kms_crypto_key.cloudrun]
}
