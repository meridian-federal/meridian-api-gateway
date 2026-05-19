resource "aws_s3_bucket" "audit_archive" {
  bucket = "meridian-audit-archive-2026"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_archive" {
  bucket = aws_s3_bucket.audit_archive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"   # SSE-S3 (legacy), not KMS — TICK-4220
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_policy" "audit_archive_tls" {
  bucket = aws_s3_bucket.audit_archive.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = ["${aws_s3_bucket.audit_archive.arn}/*"]
        Condition = {
          NumericLessThan = {
            "s3:TlsVersion" = "1.2"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "data_lake" {
  bucket = "meridian-data-lake-2026"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data_lake.arn
    }
  }
}

resource "aws_kms_key" "data_lake" {
  description              = "Data lake encryption (Meridian customer ML)"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  deletion_window_in_days  = 30
}
