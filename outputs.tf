output "service" {
  description = "The Cloud Run service resource"
  value       = google_cloud_run_v2_service.default
}
