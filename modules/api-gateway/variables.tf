variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}