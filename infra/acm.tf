resource "aws_acm_certificate" "api" {
  domain_name       = "api.meridian-federal.com"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  subject_alternative_names = [
    "*.api.meridian-federal.com",
  ]

  lifecycle { create_before_destroy = true }

  tags = {
    Service = "meridian-api-gateway"
  }
}
