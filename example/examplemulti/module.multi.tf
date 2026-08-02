# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root

resource "google_service_account" "frontend" {
  project      = var.project
  account_id   = "cloudrun-frontend-sa"
  display_name = "Cloud Run frontend service account"
}

resource "google_service_account" "backend" {
  project      = var.project
  account_id   = "cloudrun-backend-sa"
  display_name = "Cloud Run backend service account"
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

# holden:ignore:HLD_TF_026: this is an example
# holden:ignore:HLD_TF_078
module "frontend" {
  source          = "../../"
  project         = var.project
  service_account = google_service_account.frontend.email
  encryption_key  = google_kms_crypto_key.cloudrun.id
  vpc_connector   = data.google_vpc_access_connector.cloudrun.id
  containers = [
    {
      name           = "frontend"
      container_port = 8080
      image          = "nginx:1.27.4"
      depends_on     = null
      env = {
        name              = "frontend"
        REACT_APP_DEV_URL = module.backend.service.uri
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
    name         = "frontend-service"
    location     = "us-central1"
    launch_stage = "BETA"
    ingress      = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  }
}

# holden:ignore:HLD_TF_026:  this is an example
# holden:ignore:HLD_TF_078
module "backend" {
  source          = "../../"
  project         = var.project
  service_account = google_service_account.backend.email
  encryption_key  = google_kms_crypto_key.cloudrun.id
  vpc_connector   = data.google_vpc_access_connector.cloudrun.id
  containers = [
    {
      name           = "backend"
      container_port = 8080
      image          = "nginx:1.27.4"
      depends_on     = null
      env = {
        name = "backend"
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
    name         = "backend-service"
    location     = "us-central1"
    launch_stage = "BETA"
    ingress      = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  }
}
