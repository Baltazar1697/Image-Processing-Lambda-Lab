resource "aws_sns_topic_subscription" "this" {
  topic_arn = var.topic_arn
  protocol  = "lambda"
  endpoint  = var.endpoint

  depends_on = [aws_lambda_permission.allow_sns]
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowSNSInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = var.endpoint
  principal     = "sns.amazonaws.com"
  source_arn    = var.topic_arn
}
