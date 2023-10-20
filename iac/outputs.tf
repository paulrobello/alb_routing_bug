output "api_key_value" {
  value     = random_string.api_key.result
  sensitive = false
}

output "alb_invoke_url" {
  value = "http://${aws_lb.alb.dns_name}:4566/${var.stage_name}"
}
