resource "google_cloud_run_v2_service" "default" {
  provider     = google-beta

  name         = var.service.name
  location     = var.service.location
  launch_stage = var.service.launch_stage
  ingress      = var.service.ingress

  template {
    dynamic "containers" {
      for_each = var.containers
      content {
        name = containers.value["name"]
        ports {
          container_port = containers.value["container_port"]
        }
        image      = containers.value["image"]
        depends_on = containers.value["depends_on"]

      }
    }
  }
  
  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
}


variable "containers" {
  type = list(object({
    name           = string
    container_port = number
    image          = string
    depends_on     = list(string)
    volume_mounts = object({
      name       = string
      mount_path = string
    })
  }))
  description = "Cloud Run containers"
}

variable "service" {
  type = object({
    name         = string
    location     = string
    launch_stage = string
    ingress      = string
  })
  description = ""
}