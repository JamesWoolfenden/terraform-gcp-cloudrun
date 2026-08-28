resource "google_cloud_run_v2_service_iam_binding" "invokers" {
  count = length(var.invokers) == 0 ? 0 : 1

  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  members  = var.invokers
}
