# API Gateway REST API
resource "aws_api_gateway_rest_api" "prime_api" {
  name        = var.api_name
  description = "API Gateway for Prime Checker Lambda"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API Gateway Resource
resource "aws_api_gateway_resource" "prime_resource" {
  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  parent_id   = aws_api_gateway_rest_api.prime_api.root_resource_id
  path_part   = "prime"
}

# API Gateway Method
resource "aws_api_gateway_method" "prime_post" {
  rest_api_id   = aws_api_gateway_rest_api.prime_api.id
  resource_id   = aws_api_gateway_resource.prime_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  resource_id = aws_api_gateway_resource.prime_resource.id
  http_method = aws_api_gateway_method.prime_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.lambda_function_arn}/invocations"
}

# API Gateway Method Response
resource "aws_api_gateway_method_response" "prime_response_200" {
  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  resource_id = aws_api_gateway_resource.prime_resource.id
  http_method = aws_api_gateway_method.prime_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# CORS OPTIONS method
resource "aws_api_gateway_method" "prime_options" {
  rest_api_id   = aws_api_gateway_rest_api.prime_api.id
  resource_id   = aws_api_gateway_resource.prime_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "prime_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  resource_id = aws_api_gateway_resource.prime_resource.id
  http_method = aws_api_gateway_method.prime_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

resource "aws_api_gateway_method_response" "prime_options_200" {
  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  resource_id = aws_api_gateway_resource.prime_resource.id
  http_method = aws_api_gateway_method.prime_options.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "prime_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  resource_id = aws_api_gateway_resource.prime_resource.id
  http_method = aws_api_gateway_method.prime_options.http_method
  status_code = aws_api_gateway_method_response.prime_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "prime_deployment" {
  depends_on = [
    aws_api_gateway_method.prime_post,
    aws_api_gateway_method.prime_options,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.prime_options_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.prime_api.id
  stage_name  = var.stage_name
}

# Data source for current AWS region
data "aws_region" "current" {}