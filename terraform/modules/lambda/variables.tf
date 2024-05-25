variable "lambda_timeout" {
  type = number
  default = 60
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "image_uri" {
  description = "The URI of the container image in ECR"
  type        = string
}

variable "environment_variables" {
  description = "The environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  type        = string
}
