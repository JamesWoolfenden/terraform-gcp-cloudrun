variable "containers" {
  type = list(object({
    name           = string
    container_port = number
    image          = string
    depends_on     = list(string)
    env            = map(string)
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

variable "labels" {
  type        = map(string)
  description = "labels/tags"
}

variable "project" {
  type = string
}

variable "service_account" {
  type = string
}