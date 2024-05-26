
resource "aws_iam_policy" "s3_access_policy" {
  name        = "S3AccessPolicy"
  description = "Policy to allow Lambda functions to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = var.lambda_execution_role_name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowLambdaS3Access",
        Effect: "Allow",
        Principal: {
          AWS: "${var.lambda_execution_role_arn}"
        },
        Action: [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource: [
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}