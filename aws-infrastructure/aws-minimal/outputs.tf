output "bucket_id" {
  description = "Name of the smoke-test S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the smoke-test S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "account_id" {
  description = "AWS account ID where resources were created"
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region where resources were created"
  value       = var.region
}
