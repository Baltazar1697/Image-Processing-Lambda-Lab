
variable "topic_arn" {
  description = "The ARN of the SNS topic"
  type        = string
}

variable "endpoint" {
  description = "The ARN of the Lambda function to trigger"
  type        = string
}
