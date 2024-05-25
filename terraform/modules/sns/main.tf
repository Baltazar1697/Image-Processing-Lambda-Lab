resource "aws_sns_topic" "this" {
  name = var.topic_name
}
resource "aws_sns_topic_policy" "this" {
  arn = aws_sns_topic.this.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = "*",
        Action = "SNS:Publish",
        Resource = aws_sns_topic.this.arn,
        Condition = {
          ArnLike = {
            "aws:SourceArn": "arn:aws:s3:::${var.bucket_name}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_id

  topic {
    topic_arn     = aws_sns_topic.this.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "upload/"
  }
}
