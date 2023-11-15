provider "google" {
  project     = "pike-gcp"
  credentials = "/Users/jwoolfenden/pike-service.json"
}

provider "google-beta" {
  project = "pike-gcp"
}
