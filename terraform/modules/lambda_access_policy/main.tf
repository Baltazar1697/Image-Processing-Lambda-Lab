
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = var.lambda_execution_role_name
  policy_arn = var.s3_access_policy_arn
}
