# holden:ignore:HLD_GCP_059 — per-repo WIF SA with attribute.repository scoping
# provides equivalent least-privilege without impersonation.
provider "google" {

  # default labels applied to resources created by this provider
  default_labels = {
    created_by = "terraform"
    module     = "terraform-gcp-cloudrun"
  }

}
