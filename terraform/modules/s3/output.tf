
output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}
