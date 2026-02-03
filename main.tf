# Main Terraform configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Lambda module
module "prime_checker_lambda" {
  source = "./modules/lambda"
  
  function_name = var.lambda_function_name
  aws_region    = var.aws_region
}

# API Gateway module
module "prime_api_gateway" {
  source = "./modules/api-gateway"
  
  api_name           = var.api_name
  stage_name         = var.stage_name
  lambda_function_arn = module.prime_checker_lambda.lambda_function_arn
  lambda_function_name = module.prime_checker_lambda.lambda_function_name
}