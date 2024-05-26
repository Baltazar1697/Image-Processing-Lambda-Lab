terraform {
  backend "s3" {
    bucket  = "lambda-testing-state-bucket"
    key     = "prod/terraform.tfstate"
    region  = "us-west-2"
    profile = "k8s-test-project"
  }
}
provider "aws" {
  region = "eu-north-1"
  profile = "k8s-test-project"
}

locals {
  lambdas = [
    { name = "resize", timeout = 10 },
    { name = "crop", timeout = 15 },
    { name = "black-white", timeout = 20 }
  ]
}

module "sns" {
  source     = "../../modules/sns"
  topic_name = "s3-event-topic"
  bucket_id = module.s3.bucket_id
  bucket_name = module.s3.bucket_name
  depends_on = [ module.s3 ]

}

module "ecr" {
  source = "../../modules/ecr"

  for_each = { for lambda in local.lambdas : lambda.name => lambda }

  repository_name = each.value.name
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "learning-image-processing-bucket"
  tags = {
    Environment = "prod"
  }
}


module "lambda" {
  source = "../../modules/lambda"

  for_each = { for lambda in local.lambdas : lambda.name => lambda }

  function_name = each.value.name
  image_uri     = "${module.ecr[each.key].repository_url}:latest"
  environment_variables = {
    ENV = "prod"
  }
  lambda_timeout = each.value.timeout
  sns_topic_arn  = module.sns.sns_topic_arn
  depends_on     = [module.sns, module.ecr]
}

module "sns_subscription" {
  source = "../../modules/sns_subscription"

  for_each = { for lambda in local.lambdas : lambda.name => lambda }

  topic_arn  = module.sns.sns_topic_arn
  endpoint   = module.lambda[each.key].lambda_function_arn
  depends_on = [module.sns, module.lambda]
}

module "s3_policy_attachment" {
  source = "../../modules/s3_policy_attachment"
  bucket_name = module.s3.bucket_name
  lambda_execution_role_arn = module.lambda.lambda_execution_role_arn
  lambda_execution_role_name = module.lambda.lambda_execution_role_name
  depends_on = [ module.s3, module.lambda ]
}
