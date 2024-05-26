resource "aws_lambda_function" "this" {
  function_name = var.function_name
  package_type  = "Image"
  role          = aws_iam_role.lambda_execution_role.arn
  image_uri     = var.image_uri
  timeout       = var.lambda_timeout

  environment {
    variables = var.environment_variables
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_execution_role
  ]
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

resource "aws_iam_role" "lambda_execution_role" {
  name = var.function_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

