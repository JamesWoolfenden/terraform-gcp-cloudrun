# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "cloudrun" {
  source          = "../../"
  project         = "pike-477416"
  service_account = null
  containers = [
    {
      name           = "backend"
      container_port = 80
      image          = "nginx"
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
  service = {
    name         = "cloudrun-service"
    location     = "us-central1"
    launch_stage = "BETA"
    ingress      = "INGRESS_TRAFFIC_ALL"
  }

  labels = {
    pike = "permissions"
  }
}
