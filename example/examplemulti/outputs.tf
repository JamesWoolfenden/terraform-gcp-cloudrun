output "backend" {
  description = "Backend module outputs"
  value       = module.backend
  sensitive   = true
}

output "frontend" {
  description = "Frontend module outputs"
  value       = module.frontend
  sensitive   = true
}
