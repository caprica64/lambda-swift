output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.prime_api_gateway.api_gateway_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.prime_api_gateway.api_gateway_id
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.prime_checker_lambda.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.prime_checker_lambda.lambda_function_name
}