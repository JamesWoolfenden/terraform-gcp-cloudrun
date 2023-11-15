module "cloudrun" {
  source = "../../"
  containers = [
    {
      name           = "first"
      container_port = 8080
      image          = "nginx"
      depends_on     = null
      volume_mounts = {
        name       = "empty-dir-volume"
        mount_path = "/mnt"
      }
    },
    {
      name           = "second"
      container_port = 8081
      image          = "nginx"
      depends_on     = null
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
}
