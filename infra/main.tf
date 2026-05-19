terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_kms_key" "signing" {
  description              = "API gateway JWT signing key"
  customer_master_key_spec = "RSA_2048"
  key_usage                = "SIGN_VERIFY"
  deletion_window_in_days  = 30

  tags = {
    Service = "meridian-api-gateway"
    Crypto  = "RSA-2048"
  }
}

resource "aws_kms_key" "envelope" {
  description              = "API request envelope encryption"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  deletion_window_in_days  = 30
}

resource "aws_secretsmanager_secret" "signing_key_backup" {
  name                    = "meridian-api-gateway/signing-key-backup"
  description             = "PEM-encoded backup of the JWT signing key"
  recovery_window_in_days = 7
}

resource "aws_key_pair" "deployment" {
  key_name   = "meridian-api-gateway-deploy"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx meridian-demo@meridian-federal"
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.api.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

resource "aws_lb" "api" {
  name               = "meridian-api-gateway"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.subnets
}

resource "aws_lb_target_group" "api" {
  name     = "meridian-api"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

variable "subnets" { type = list(string) }
variable "vpc_id"  { type = string }
