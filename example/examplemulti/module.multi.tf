module "frontend" {
  source  = "../../"
  project = "pike-gcp"
  containers = [
    {
      name           = "frontend"
      container_port = 80
      image          = "nginx"
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
  service = {
    name         = "frontend-service"
    location     = "us-central1"
    launch_stage = "BETA"
    ingress      = "INGRESS_TRAFFIC_ALL"
  }

  labels = {
    pike = "permissions"
  }
}

module "backend" {
  source  = "../../"
  project = "pike-gcp"
  containers = [
    {
      name           = "backend"
      container_port = 80
      image          = "nginx"
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
  service = {
    name         = "backend-service"
    location     = "us-central1"
    launch_stage = "BETA"
    ingress      = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  }

  labels = {
    pike = "permissions"
  }
}
