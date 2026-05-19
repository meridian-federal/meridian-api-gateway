resource "aws_db_instance" "ledger_audit" {
  identifier             = "meridian-ledger-audit"
  engine                 = "postgres"
  engine_version         = "13.7"
  instance_class         = "db.r5.xlarge"
  allocated_storage      = 500
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds.arn
  username               = "meridian_audit"
  manage_master_user_password = true
  publicly_accessible    = false
  multi_az               = true
  backup_retention_period = 30
  parameter_group_name   = aws_db_parameter_group.legacy_tls.name
  skip_final_snapshot    = false
  iam_database_authentication_enabled = false
}

resource "aws_db_parameter_group" "legacy_tls" {
  name   = "meridian-ledger-pg13-legacy-tls"
  family = "postgres13"

  parameter {
    name  = "rds.force_ssl"
    value = "0"   # Legacy partner reporting tools require non-TLS — TICK-3104
  }
  parameter {
    name  = "ssl_min_protocol_version"
    value = "TLSv1.1"
  }
}

resource "aws_kms_key" "rds" {
  description              = "RDS encryption key (Meridian audit DB)"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
  enable_key_rotation      = false   # Disabled — rotation runbook not yet automated
  deletion_window_in_days  = 30
}
