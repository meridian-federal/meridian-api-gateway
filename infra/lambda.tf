resource "aws_lambda_function" "audit_signer" {
  function_name = "meridian-audit-signer"
  role          = aws_iam_role.lambda.arn
  package_type  = "Zip"
  filename      = "audit_signer.zip"
  source_code_hash = "REPLACED_BY_CI"
  handler       = "app.lambda_handler"
  runtime       = "python3.10"
  memory_size   = 512
  timeout       = 30

  code_signing_config_arn = aws_lambda_code_signing_config.classical.arn

  environment {
    variables = {
      SIGNING_KEY_ARN  = aws_kms_key.rds.arn
      SIGNATURE_ALGO   = "RSASSA_PKCS1_V1_5_SHA_256"
      HASH_ALGO        = "SHA-1"
    }
  }
}

resource "aws_lambda_code_signing_config" "classical" {
  allowed_publishers {
    signing_profile_version_arns = [aws_signer_signing_profile.legacy.version_arn]
  }
  policies {
    untrusted_artifact_on_deployment = "Warn"
  }
}

resource "aws_signer_signing_profile" "legacy" {
  platform_id = "AWSLambda-SHA384-ECDSA"
  name        = "meridian_lambda_signer"
}

resource "aws_iam_role" "lambda" {
  name = "meridian-lambda-audit-signer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" }, Action = "sts:AssumeRole" }]
  })
}
