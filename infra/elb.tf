resource "aws_lb_listener" "partner_legacy_tls" {
  load_balancer_arn = aws_lb.api.arn
  port              = 8443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"   # TLS 1.1 — partner bank legacy
  certificate_arn   = aws_acm_certificate.api.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_acm_certificate" "partner_mtls" {
  domain_name       = "partners.meridian-federal.com"
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"

  subject_alternative_names = ["mtls.partners.meridian-federal.com"]

  lifecycle { create_before_destroy = true }
}

resource "aws_acm_certificate" "edge" {
  domain_name       = "edge.meridian-federal.com"
  validation_method = "DNS"
  key_algorithm     = "EC_secp384r1"   # ECDSA P-384

  lifecycle { create_before_destroy = true }
}
