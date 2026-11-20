locals {
  # Built from known names, not google_kms_crypto_key.cloudrun.id, so the
  # module's count on encryption_key is decidable at plan time.
  cloudrun_key_id = "projects/${var.project}/locations/us-central1/keyRings/cloudrun-keyring/cryptoKeys/cloudrun-key"
}
