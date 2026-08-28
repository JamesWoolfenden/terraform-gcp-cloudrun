variable "containers" {
  type = list(object({
    name           = string
    container_port = number
    image          = string
    depends_on     = list(string)
    env            = map(string)
    secret_env = optional(list(object({
      name    = string
      secret  = string
      version = string
    })), [])
    volume_mounts = optional(object({
      name       = string
      mount_path = string
    }))
  }))
  description = "Cloud Run containers"

  validation {
    condition     = length(var.containers) > 0
    error_message = "containers must contain at least one container definition"
  }
}

variable "volumes" {
  type = list(object({
    name = string
    empty_dir = optional(object({
      medium     = optional(string, "MEMORY")
      size_limit = optional(string)
    }))
  }))
  default     = []
  description = "Template-level volumes; each name must be referenced by a container volume_mounts entry"

  validation {
    condition = alltrue([
      for vol in var.volumes :
      contains([
        for c in var.containers :
        try(c.volume_mounts.name, "")
      ], vol.name)
    ])
    error_message = "Each volume must be referenced by at least one container volume_mounts entry"
  }
}

variable "service" {
  type = object({
    name         = string
    location     = string
    launch_stage = string
    ingress      = string
  })
  description = "Cloud Run service configuration"

  validation {
    condition     = length(trimspace(var.service.name)) > 0
    error_message = "service.name must be a non-empty string"
  }
}

variable "project" {
  type        = string
  description = "GCP project ID"

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty string"
  }
}

variable "service_account" {
  type        = string
  description = "Service account email to run the Cloud Run service as"

  validation {
    condition     = length(trimspace(var.service_account)) > 0
    error_message = "service_account must be a non-empty string"
  }
}

variable "vpc_connector" {
  type        = string
  description = "VPC connector ID for Cloud Run VPC egress; if null the vpc_access block is omitted"

  validation {
    condition     = var.vpc_connector == null || length(trimspace(var.vpc_connector)) > 0
    error_message = "vpc_connector must be a non-empty string or null"
  }
}

variable "vpc_egress" {
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
  description = "VPC Access Connector egress setting; PRIVATE_RANGES_ONLY routes only RFC-1918 traffic through the connector, ALL_TRAFFIC forces all egress through VPC (requires Cloud NAT for internet access)"

  validation {
    condition     = contains(["PRIVATE_RANGES_ONLY", "ALL_TRAFFIC"], var.vpc_egress)
    error_message = "vpc_egress must be PRIVATE_RANGES_ONLY or ALL_TRAFFIC"
  }
}

variable "encryption_key" {
  type        = string
  description = "KMS key resource name for CMEK encryption of container instances; if null uses Google-managed key"
  sensitive   = true

  validation {
    condition     = var.encryption_key == null || length(trimspace(var.encryption_key)) > 0
    error_message = "encryption_key must be a non-empty string or null"
  }
}

variable "min_instance_count" {
  type        = number
  default     = 0
  description = "Minimum number of container instances to keep warm; 0 allows scale-to-zero (matches Cloud Run's own default). Set to null to omit the setting from the scaling block entirely instead of explicitly requesting 0."

  validation {
    condition     = var.min_instance_count == null || var.min_instance_count >= 0
    error_message = "min_instance_count must be a non-negative number or null"
  }
}

variable "max_instance_count" {
  type        = number
  default     = 100
  description = "Maximum number of container instances Cloud Run may scale to; 100 matches Cloud Run's own default per-revision ceiling. Set to null to omit the setting from the scaling block entirely instead of explicitly requesting 100."

  validation {
    condition     = var.max_instance_count == null || var.max_instance_count > 0
    error_message = "max_instance_count must be a positive number or null"
  }
}

variable "startup_probe" {
  type = object({
    initial_delay_seconds = optional(number)
    timeout_seconds       = optional(number)
    period_seconds        = optional(number)
    failure_threshold     = optional(number)
    http_get = optional(object({
      path = optional(string)
      port = optional(number)
      http_headers = optional(list(object({
        name  = string
        value = optional(string)
      })), [])
    }))
    tcp_socket = optional(object({
      port = optional(number)
    }))
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }))
  })
  default     = null
  description = "Startup probe applied to the primary (first) container; null uses Cloud Run's default TCP-open probe. Set exactly one of http_get, tcp_socket, or grpc."

  validation {
    condition = var.startup_probe == null || length(compact([
      var.startup_probe.http_get != null ? "http_get" : "",
      var.startup_probe.tcp_socket != null ? "tcp_socket" : "",
      var.startup_probe.grpc != null ? "grpc" : "",
    ])) == 1
    error_message = "startup_probe must set exactly one of http_get, tcp_socket, or grpc"
  }
}

variable "liveness_probe" {
  type = object({
    initial_delay_seconds = optional(number)
    timeout_seconds       = optional(number)
    period_seconds        = optional(number)
    failure_threshold     = optional(number)
    http_get = optional(object({
      path = optional(string)
      port = optional(number)
      http_headers = optional(list(object({
        name  = string
        value = optional(string)
      })), [])
    }))
    grpc = optional(object({
      port    = optional(number)
      service = optional(string)
    }))
    tcp_socket = optional(object({
      port = optional(number)
    }))
  })
  default     = null
  description = "Liveness probe applied to the primary (first) container; null means no liveness probe is configured (Cloud Run relies on the container staying up, with no active restart-on-hang check)."

  validation {
    condition = var.liveness_probe == null || length(compact([
      var.liveness_probe.http_get != null ? "http_get" : "",
      var.liveness_probe.tcp_socket != null ? "tcp_socket" : "",
      var.liveness_probe.grpc != null ? "grpc" : "",
    ])) <= 1
    error_message = "liveness_probe must set at most one of http_get, tcp_socket, or grpc"
  }
}

variable "private_check_endpoint" {
  type = object({
    ip                         = string
    port                       = number
    network                    = string
    service_directory_location = string
  })
  default     = null
  description = <<-EOT
    Optional private target for a VPC-based (VPC_CHECKERS) uptime check,
    used only when service.ingress is not INGRESS_TRAFFIC_ALL. Point it at
    the internal IP:port of whatever fronts this service on the private
    network - an internal Application Load Balancer forwarding rule (for
    INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER) or a Private Service Connect
    endpoint (for INGRESS_TRAFFIC_INTERNAL_ONLY). This module registers that
    endpoint in Service Directory and points the uptime check at it; it does
    not create the load balancer/PSC endpoint itself, since it doesn't own
    that network topology.

    `network` is the target VPC's self-link in the form
    projects/PROJECT_NUMBER/locations/global/networks/NETWORK_NAME.
    `service_directory_location` is the region for the Service Directory
    namespace, e.g. "us-central1" - typically the same region as the service.

    The caller must separately allow inbound TCP from 35.199.192.0/19 on
    that network, and grant the Cloud Monitoring service agent
    roles/servicedirectory.viewer and roles/servicedirectory.pscAuthorizedService
    - this module does not manage that network's firewall rules or IAM.

    If left null while ingress is restricted, no uptime check is created at
    all - there's nothing reachable to monitor without an endpoint.
  EOT

  validation {
    condition     = var.private_check_endpoint == null || (var.private_check_endpoint.port > 0 && var.private_check_endpoint.port <= 65535)
    error_message = "private_check_endpoint.port must be a valid TCP port (1-65535)"
  }
}

variable "invokers" {
  type        = list(string)
  description = "Principals granted roles/run.invoker on the service, authoritatively for that role. Empty to create no binding"
  default     = []

  validation {
    condition     = !anytrue([for m in var.invokers : contains(["allUsers", "allAuthenticatedUsers"], m)])
    error_message = "var.invokers must not contain allUsers or allAuthenticatedUsers, an unauthenticated Cloud Run service should say so explicitly"
  }
}

variable "worker_pool_image" {
  type        = string
  description = "Container image run by a Cloud Run worker pool alongside the service. Empty to create no worker pool"
  default     = ""

  validation {
    condition     = var.worker_pool_image == "" || !can(regex(":latest$", var.worker_pool_image))
    error_message = "var.worker_pool_image must be pinned to a digest or version tag, not :latest"
  }
}

variable "worker_pool_service_account" {
  type        = string
  description = "Email of the service account the worker pool runs as"
  default     = ""

  validation {
    condition     = var.worker_pool_service_account == "" || can(regex("^[^@]+@[^@]+$", var.worker_pool_service_account))
    error_message = "var.worker_pool_service_account must be a service account email address"
  }
}

variable "legacy_service_image" {
  type        = string
  description = "Container image for a v1 (google_cloud_run_service) deployment kept alongside the v2 service during migration. Empty to create no v1 service"
  default     = ""

  validation {
    condition     = var.legacy_service_image == "" || !can(regex(":latest$", var.legacy_service_image))
    error_message = "var.legacy_service_image must be pinned to a digest or version tag, not :latest"
  }
}

variable "legacy_service_account" {
  type        = string
  description = "Email of the service account the v1 service runs as"
  default     = ""

  validation {
    condition     = var.legacy_service_account == "" || can(regex("^[^@]+@[^@]+$", var.legacy_service_account))
    error_message = "var.legacy_service_account must be a service account email address"
  }
}
