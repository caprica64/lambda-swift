variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "prime-checker-api"
}

variable "stage_name" {
  description = "Stage name for API Gateway deployment"
  type        = string
  default     = "dev"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "prime-checker"
}