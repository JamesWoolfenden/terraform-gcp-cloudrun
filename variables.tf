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

  validation {
    condition     = var.encryption_key == null || length(trimspace(var.encryption_key)) > 0
    error_message = "encryption_key must be a non-empty string or null"
  }
}
