resource "google_cloud_run_v2_service" "default" {
  provider = google-beta

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
        dynamic "env" {
          for_each = containers.value["env"]
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
  }

  labels = var.labels

  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
}
