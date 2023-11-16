module "cloudrun" {
  source  = "../../"
  project = "pike-gcp"
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
