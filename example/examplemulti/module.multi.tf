# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root

resource "google_service_account" "frontend" {
  project      = "pike-477416"
  account_id   = "cloudrun-frontend-sa"
  display_name = "Cloud Run frontend service account"
}

resource "google_service_account" "backend" {
  project      = "pike-477416"
  account_id   = "cloudrun-backend-sa"
  display_name = "Cloud Run backend service account"
}

resource "google_kms_key_ring" "cloudrun" {
  project  = "pike-477416"
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
  project = "pike-477416"
  name    = "cloudrun-connector"
  region  = "us-central1"
}

resource "google_kms_crypto_key_iam_member" "cloudrun_sa" {
  crypto_key_id = google_kms_crypto_key.cloudrun.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

module "frontend" {
  source          = "../../"
  project         = "pike-477416"
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

module "backend" {
  source          = "../../"
  project         = "pike-477416"
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
