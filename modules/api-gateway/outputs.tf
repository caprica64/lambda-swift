output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = aws_api_gateway_deployment.prime_deployment.invoke_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.prime_api.id
}

output "api_gateway_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.prime_api.arn
}