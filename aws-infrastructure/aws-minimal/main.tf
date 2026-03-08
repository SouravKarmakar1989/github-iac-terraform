# ---------------------------------------------------------------------------
# aws-minimal — smoke-test module
#
# Creates a private, versioned, server-side-encrypted S3 bucket.
# Equivalent to azure-minimal: proves authentication, state backend, and
# provider configuration are all working end-to-end.
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket        = "${local.prefix}-smoke-${data.aws_caller_identity.current.account_id}"
  force_destroy = var.environment != "prod"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Current caller identity — used in bucket name to ensure global uniqueness
data "aws_caller_identity" "current" {}
