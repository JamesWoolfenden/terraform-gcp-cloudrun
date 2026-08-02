variable "project" {
  type        = string
  default     = "pike-477416"
  description = "GCP project ID to deploy the example into"

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must be a non-empty string"
  }
}
