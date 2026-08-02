locals {
  default_resource_limits = {
    cpu    = "1"
    memory = "512Mi"
  }

  # Pre-derive the per-container shape (resource limits, env entries, volume
  # mounts) once here instead of re-deriving it inline on every dynamic
  # "containers" iteration - keeps the resource block itself to plain
  # attribute references.
  containers_normalized = [
    for c in var.containers : {
      name           = c["name"]
      container_port = c["container_port"]
      image          = c["image"]
      depends_on     = c["depends_on"]
      volume_mounts  = try(c["volume_mounts"], [])
      resource_limits = coalesce(
        lookup(try(c["resources"], {}), "limits", null),
        local.default_resource_limits
      )
      env_entries = concat(
        [for k, v in try(c["env"], {}) : { name = k, value = v, secret = null, version = null, value_source_items = [] }],
        [for secret in try(c["secret_env"], []) : { name = secret.name, value = null, secret = secret.secret, version = secret.version, value_source_items = [1] }]
      )
    }
  ]

  vpc_access_items = var.vpc_connector != null ? [1] : []

  volumes_normalized = [
    for v in var.volumes : {
      name            = v["name"]
      empty_dir_items = v["empty_dir"] != null ? [v["empty_dir"]] : []
    }
  ]

  # Google's public uptime checkers can only ever reach a fully public
  # service; a restricted ingress needs a private (VPC_CHECKERS) check
  # instead, and only when the caller has given us something reachable to
  # point it at.
  uptime_check_public  = var.service.ingress == "INGRESS_TRAFFIC_ALL"
  uptime_check_private = !local.uptime_check_public && var.private_check_endpoint != null
}

# holden:ignore:HLD_TF_063_HIGH  # 7 dynamic blocks (vpc_access/volumes/empty_dir/containers/env/value_source/volume_mounts) are each individually optional per the module's public interface; all extractable ternary/for/lookup logic already lives in locals above.
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
    # request timeout (defaults to 300s if not provided)
    timeout         = try(var.service.timeout, "300s")
    service_account = var.service_account
    encryption_key  = var.encryption_key

    dynamic "scaling" {
      for_each = var.min_instance_count != null || var.max_instance_count != null ? [1] : []
      content {
        min_instance_count = var.min_instance_count
        max_instance_count = var.max_instance_count
      }
    }

    dynamic "vpc_access" {
      for_each = local.vpc_access_items
      content {
        connector = var.vpc_connector
        egress    = var.vpc_egress
      }
    }

    dynamic "volumes" {
      for_each = local.volumes_normalized
      content {
        name = volumes.value.name
        dynamic "empty_dir" {
          for_each = volumes.value.empty_dir_items
          content {
            medium     = empty_dir.value["medium"]
            size_limit = empty_dir.value["size_limit"]
          }
        }
      }
    }

    dynamic "containers" {
      for_each = local.containers_normalized
      content {
        name = containers.value.name
        ports {
          container_port = containers.value.container_port
        }
        image      = containers.value.image
        depends_on = containers.value.depends_on

        resources {
          limits = containers.value.resource_limits
        }

        # Probes apply per-container; Cloud Run treats the first container as
        # the one serving ingress traffic, so that's the only one these are
        # attached to - a sidecar getting the ingress container's health
        # checks would be wrong.
        dynamic "startup_probe" {
          for_each = containers.key == 0 && var.startup_probe != null ? [var.startup_probe] : []
          content {
            initial_delay_seconds = startup_probe.value.initial_delay_seconds
            timeout_seconds       = startup_probe.value.timeout_seconds
            period_seconds        = startup_probe.value.period_seconds
            failure_threshold     = startup_probe.value.failure_threshold

            dynamic "http_get" {
              for_each = startup_probe.value.http_get != null ? [startup_probe.value.http_get] : []
              content {
                path = http_get.value.path
                port = http_get.value.port

                dynamic "http_headers" {
                  for_each = http_get.value.http_headers
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = startup_probe.value.tcp_socket != null ? [startup_probe.value.tcp_socket] : []
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = startup_probe.value.grpc != null ? [startup_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }

        dynamic "liveness_probe" {
          for_each = containers.key == 0 && var.liveness_probe != null ? [var.liveness_probe] : []
          content {
            initial_delay_seconds = liveness_probe.value.initial_delay_seconds
            timeout_seconds       = liveness_probe.value.timeout_seconds
            period_seconds        = liveness_probe.value.period_seconds
            failure_threshold     = liveness_probe.value.failure_threshold

            dynamic "http_get" {
              for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
              content {
                path = http_get.value.path
                port = http_get.value.port

                dynamic "http_headers" {
                  for_each = http_get.value.http_headers
                  content {
                    name  = http_headers.value.name
                    value = http_headers.value.value
                  }
                }
              }
            }

            dynamic "tcp_socket" {
              for_each = liveness_probe.value.tcp_socket != null ? [liveness_probe.value.tcp_socket] : []
              content {
                port = tcp_socket.value.port
              }
            }

            dynamic "grpc" {
              for_each = liveness_probe.value.grpc != null ? [liveness_probe.value.grpc] : []
              content {
                port    = grpc.value.port
                service = grpc.value.service
              }
            }
          }
        }

        dynamic "env" {
          for_each = containers.value.env_entries
          content {
            name  = env.value.name
            value = env.value.value

            dynamic "value_source" {
              for_each = env.value.value_source_items
              content {
                secret_key_ref {
                  secret  = env.value.secret
                  version = env.value.version
                }
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = containers.value.volume_mounts
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

# Google's public uptime checkers run outside the customer's VPC, so they
# can't reach a service whose ingress restricts traffic to INTERNAL_ONLY or
# INTERNAL_LOAD_BALANCER - creating a public check against such a service
# would just fail permanently. Only create the public check when ingress is
# unrestricted; when it's restricted, a private (VPC_CHECKERS) check is
# created instead, but only if the caller supplies a reachable endpoint via
# var.private_check_endpoint - this module doesn't own the internal load
# balancer / PSC endpoint that endpoint depends on, so it can't conjure one.
moved {
  from = google_monitoring_uptime_check_config.cloud_run_service
  to   = google_monitoring_uptime_check_config.public[0]
}

resource "google_monitoring_uptime_check_config" "public" {
  count = local.uptime_check_public ? 1 : 0

  project      = var.project
  display_name = "${google_cloud_run_v2_service.default.name}-uptime-check"
  timeout      = "10s"
  period       = "60s"

  monitored_resource {
    type = "uptime_url"
    labels = {
      host = replace(replace(google_cloud_run_v2_service.default.uri, "https://", ""), "http://", "")
    }
  }

  http_check {
    path    = "/"
    port    = 443
    use_ssl = true
  }
}

resource "google_service_directory_namespace" "uptime" {
  count = local.uptime_check_private ? 1 : 0

  project      = var.project
  namespace_id = "${var.service.name}-uptime"
  location     = var.private_check_endpoint.service_directory_location
}

resource "google_service_directory_service" "uptime" {
  count = local.uptime_check_private ? 1 : 0

  service_id = var.service.name
  namespace  = google_service_directory_namespace.uptime[0].id
}

resource "google_service_directory_endpoint" "uptime" {
  count = local.uptime_check_private ? 1 : 0

  endpoint_id = var.service.name
  service     = google_service_directory_service.uptime[0].id
  address     = var.private_check_endpoint.ip
  port        = var.private_check_endpoint.port
  network     = var.private_check_endpoint.network
}

# Requires the caller to have already allowed inbound TCP from
# 35.199.192.0/19 on the target network, and granted the Cloud Monitoring
# service agent roles/servicedirectory.viewer and
# roles/servicedirectory.pscAuthorizedService - this module doesn't own that
# network's firewall rules or IAM, so it doesn't create them.
resource "google_monitoring_uptime_check_config" "private" {
  count = local.uptime_check_private ? 1 : 0

  project      = var.project
  display_name = "${google_cloud_run_v2_service.default.name}-uptime-check"
  timeout      = "10s"
  period       = "60s"
  checker_type = "VPC_CHECKERS"

  monitored_resource {
    type = "servicedirectory_service"
    labels = {
      project_id     = var.project
      location       = var.private_check_endpoint.service_directory_location
      namespace_name = google_service_directory_namespace.uptime[0].namespace_id
      service_name   = google_service_directory_service.uptime[0].service_id
    }
  }

  http_check {
    path    = "/"
    port    = var.private_check_endpoint.port
    use_ssl = true
  }
}

data "google_project" "current" {}

resource "google_kms_crypto_key_iam_member" "cloud_run_service_agent" {
  count = var.encryption_key != null ? 1 : 0

  crypto_key_id = var.encryption_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@serverless-robot-prod.iam.gserviceaccount.com"
}
