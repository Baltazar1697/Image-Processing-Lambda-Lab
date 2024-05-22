provider "aws" {
  region = "us-west-2"
}

locals {
  lambdas = [
    { name = "resize", timeout = 10 },
    { name = "crop", timeout = 15 },
    { name = "black-white", timeout = 20 }
  ]
}

module "s3" {
  source      = "../../modules/s3"
  bucket_name = "learning-image-cropping-bucket"
  tags = {
    Environment = "prod"
  }
}

module "ecr" {
  source = "../../modules/ecr"

  for_each = { for lambda in local.lambdas : lambda.name => lambda }

  repository_name = each.value.name
}

module "lambda" {
  source = "../../modules/lambda"

  for_each = { for lambda in local.lambdas : lambda.name => lambda }

  function_name         = each.value.name
  image_uri             = "${module.ecr[each.key].repository_url}:latest"
  environment_variables = {
    ENV = "prod"
  }
  lambda_timeout = each.value.timeout
}

module "s3_event" {
  source = "../../modules/s3_event"

  for_each = { for lambda in local.lambdas : lambda.name => lambda }

  bucket_name          = module.s3.bucket_name
  bucket_arn           = module.s3.bucket_arn
  lambda_function_arn  = module.lambda[each.key].lambda_function_name
  lambda_function_name = each.value.name
}