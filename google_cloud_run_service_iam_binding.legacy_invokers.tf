resource "google_cloud_run_service_iam_binding" "legacy_invokers" {
  count = var.legacy_service_image == "" || length(var.invokers) == 0 ? 0 : 1

  location = google_cloud_run_service.legacy[0].location
  service  = google_cloud_run_service.legacy[0].name
  role     = "roles/run.invoker"
  members  = var.invokers
}
