resource "google_cloud_run_v2_service" "default" {
  name         = var.service.name
  location     = var.service.location
  launch_stage = var.service.launch_stage
  ingress      = var.service.ingress
  project      = var.project

  binary_authorization {
    use_default = true
  }

  template {
    service_account = var.service_account
    encryption_key  = var.encryption_key

    dynamic "vpc_access" {
      for_each = var.vpc_connector != null ? [1] : []
      content {
        connector = var.vpc_connector
        egress    = var.vpc_egress
      }
    }

    dynamic "volumes" {
      for_each = var.volumes
      content {
        name = volumes.value["name"]
        dynamic "empty_dir" {
          for_each = volumes.value["empty_dir"] != null ? [volumes.value["empty_dir"]] : []
          content {
            medium     = empty_dir.value["medium"]
            size_limit = empty_dir.value["size_limit"]
          }
        }
      }
    }

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

        dynamic "env" {
          for_each = containers.value["secret_env"]
          content {
            name = env.value["name"]
            value_source {
              secret_key_ref {
                secret  = env.value["secret"]
                version = env.value["version"]
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = containers.value["volume_mounts"] != null ? [containers.value["volume_mounts"]] : []
          content {
            name       = volume_mounts.value["name"]
            mount_path = volume_mounts.value["mount_path"]
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      launch_stage,
    ]
  }
}
