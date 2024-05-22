resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  package_type  = "Image"
  role          = aws_iam_role.lambda_execution.arn
  timeout       = var.lambda_timeout

  image_uri     = var.image_uri

  environment {
    variables   = var.environment_variables
  }

  depends_on    = [
    aws_iam_role_policy_attachment.lambda_execution
  ]
}

resource "aws_iam_role" "lambda_execution" {
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

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
