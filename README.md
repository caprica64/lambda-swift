# Prime Checker & Factorial Calculator API

A production-ready Terraform-based AWS infrastructure that creates an API Gateway connected to Swift Lambda functions for prime number checking and factorial calculation. Built with modular Terraform architecture for scalability and maintainability.

## 🚀 Live API Endpoints

**Base URL**: `https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev`  
**Prime Checker**: `POST /prime`  
**Factorial Calculator**: `POST /factorial`

## 🏗️ Architecture

- **API Gateway**: Regional REST API with `/prime` and `/factorial` endpoints and CORS support
- **Lambda Functions**: Swift custom runtime with efficient algorithms for prime checking and factorial calculation
- **Unified Lambda Module**: Single, reusable Terraform module for all Lambda functions
- **X-Ray Tracing**: Distributed tracing for API Gateway and Lambda with 10% sampling rate
- **IAM Roles**: Least-privilege security with proper execution permissions
- **Modular Structure**: Organized using Terraform modules for reusability and maintainability

## 🔄 Module Flow Architecture

This project demonstrates a clean, modular Terraform architecture with clear separation of concerns:

### Module Structure

```
main.tf (Root)
    ├── module "prime_checker_lambda" (Lambda Module Instance)
    │   ├── Creates Lambda function for prime checking
    │   ├── Creates IAM role and policies
    │   ├── Creates CloudWatch log group
    │   └── Outputs: function_arn, function_name, invoke_arn, role_arn
    │
    ├── module "factorial_calculator_lambda" (Lambda Module Instance)
    │   ├── Creates Lambda function for factorial calculation
    │   ├── Creates IAM role and policies
    │   ├── Creates CloudWatch log group
    │   └── Outputs: function_arn, function_name, invoke_arn, role_arn
    │
    ├── module "xray_tracing" (X-Ray Module Instance)
    │   ├── Creates X-Ray sampling rules
    │   ├── Creates X-Ray IAM policies
    │   ├── Creates CloudWatch log group for traces
    │   └── Attaches X-Ray policy to prime_checker_lambda role
    │
    ├── module "factorial_xray_tracing" (X-Ray Module Instance)
    │   ├── Creates X-Ray sampling rules
    │   ├── Creates X-Ray IAM policies
    │   ├── Creates CloudWatch log group for traces
    │   └── Attaches X-Ray policy to factorial_calculator_lambda role
    │
    └── module "prime_api_gateway" (API Gateway Module)
        ├── Creates REST API
        ├── Creates /prime and /factorial resources
        ├── Creates POST and OPTIONS methods
        ├── Integrates with both Lambda functions using invoke_arn
        ├── Creates deployment and stage
        └── Outputs: api_gateway_url, api_gateway_id
```

### Data Flow

1. **Module Instantiation**: Root `main.tf` creates multiple instances of reusable modules
2. **Lambda Modules**: Each Lambda module outputs `invoke_arn` and `role_arn`
3. **X-Ray Modules**: X-Ray modules consume Lambda `role_arn` to attach tracing policies
4. **API Gateway Module**: Consumes Lambda `invoke_arn` outputs to create integrations
5. **Root Outputs**: Aggregates module outputs for end-user consumption

### Module Dependencies

```
Lambda Modules (Independent)
    ↓ (outputs: invoke_arn, role_arn)
    ├─→ X-Ray Modules (depends on role_arn)
    └─→ API Gateway Module (depends on invoke_arn)
```

### Unified Lambda Module Benefits

The project uses a single, parameterized Lambda module (`modules/lambda-function/`) that can be instantiated multiple times with different configurations:

- **Code Reusability**: Single module definition for all Lambda functions
- **Consistency**: Standardized infrastructure patterns across functions
- **Maintainability**: Updates to Lambda infrastructure apply to all functions
- **Flexibility**: Supports any runtime, handler, and configuration
- **Scalability**: Easy to add new Lambda functions without duplicating code
- **Clear Dependencies**: Explicit input/output flow between modules
- **Parallel Execution**: Independent modules can be created concurrently

## 📡 API Usage

### Prime Checker Endpoint
```
POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/prime
```

#### Request Format
```json
{
  "number": 17
}
```

#### Success Response
```json
{
  "number": 17,
  "isPrime": true,
  "message": "17 is a prime number"
}
```

### Factorial Calculator Endpoint
```
POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/factorial
```

#### Request Format
```json
{
  "number": 5
}
```

#### Success Response
```json
{
  "number": 5,
  "factorial": "120",
  "message": "Factorial of 5 calculated successfully",
  "calculationTime": 0.000062
}
```

### Error Response (Both Endpoints)
```json
{
  "error": "Invalid input. Please provide a valid number."
}
```

## 🧪 Testing Examples

### Prime Checker Tests
```bash
# Test with prime number
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/prime \
  -H "Content-Type: application/json" \
  -d '{"number": 17}'

# Test with composite number
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/prime \
  -H "Content-Type: application/json" \
  -d '{"number": 25}'

# Test edge cases
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/prime \
  -H "Content-Type: application/json" \
  -d '{"number": 2}'
```

### Factorial Calculator Tests
```bash
# Test small factorial
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/factorial \
  -H "Content-Type: application/json" \
  -d '{"number": 5}'

# Test larger factorial
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/factorial \
  -H "Content-Type: application/json" \
  -d '{"number": 10}'

# Test very large factorial (string-based calculation)
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/factorial \
  -H "Content-Type: application/json" \
  -d '{"number": 25}'

# Test edge case
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/factorial \
  -H "Content-Type: application/json" \
  -d '{"number": 0}'
```

### Error Handling Tests
```bash
# Test invalid input on prime endpoint
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/prime \
  -H "Content-Type: application/json" \
  -d '{"number": "invalid"}'

# Test out of range on factorial endpoint
curl -X POST https://w3172e9z33.execute-api.us-east-1.amazonaws.com/dev/factorial \
  -H "Content-Type: application/json" \
  -d '{"number": 1001}'
```

## 🛠️ Deployment

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.5.7 installed
- Docker installed (for Swift Lambda compilation)
- Valid AWS credentials

### Quick Start
1. **Clone and configure**:
   ```bash
   git clone <repository-url>
   cd api-gateway
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   ```

2. **Build Swift Lambda functions**:
   ```bash
   # Build Prime Checker Lambda
   cd modules/lambda-function/functions/prime-checker/src
   ./build.sh
   cd ../../../../..
   
   # Build Factorial Calculator Lambda
   cd modules/lambda-function/functions/factorial-calculator/src
   ./build.sh
   cd ../../../../..
   ```

3. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Test the deployment**:
   ```bash
   # Use the API Gateway URL from terraform output
   curl -X POST $(terraform output -raw api_gateway_url)/prime \
     -H "Content-Type: application/json" \
     -d '{"number": 17}'
   ```

### Configuration Variables
```hcl
aws_region              = "us-east-1"        # AWS region for deployment
api_name               = "prime-checker-api" # API Gateway name
stage_name             = "dev"               # API Gateway stage
lambda_function_name   = "prime-checker"     # Prime Lambda function name
factorial_function_name = "factorial-calculator" # Factorial Lambda function name

# X-Ray Tracing Configuration
enable_xray_tracing  = true               # Enable distributed tracing
xray_sampling_rate   = 0.1                # Sample 10% of requests (0.0 to 1.0)
log_retention_days   = 14                 # CloudWatch log retention in days
```

## 📁 Project Structure

```
├── main.tf                    # Root Terraform configuration
├── variables.tf              # Input variables
├── outputs.tf               # Output values
├── terraform.tfvars.example # Example configuration
├── .terraform.lock.hcl      # Provider version lock
├── modules/
│   ├── lambda-function/     # Unified Lambda function module (reusable)
│   │   ├── main.tf         # Lambda resources
│   │   ├── variables.tf    # Lambda variables
│   │   ├── outputs.tf      # Lambda outputs
│   │   ├── README.md       # Module documentation
│   │   └── functions/      # Function source code and packages
│   │       ├── prime-checker/
│   │       │   ├── src/    # Swift source code
│   │       │   │   ├── Package.swift           # Swift package definition
│   │       │   │   ├── build.sh               # Docker-based build script
│   │       │   │   ├── bootstrap              # Lambda runtime bootstrap (generated)
│   │       │   │   └── Sources/
│   │       │   │       └── PrimeChecker/
│   │       │   │           └── main.swift     # Swift prime checker implementation
│   │       │   └── lambda_function.zip        # Deployment package (generated)
│   │       └── factorial-calculator/
│   │           ├── src/    # Swift source code
│   │           │   ├── Package.swift           # Swift package definition
│   │           │   ├── build.sh               # Docker-based build script
│   │           │   ├── bootstrap              # Lambda runtime bootstrap (generated)
│   │           │   └── Sources/
│   │           │       └── FactorialCalculator/
│   │           │           └── main.swift     # Swift factorial calculator implementation
│   │           └── factorial_function.zip     # Deployment package (generated)
│   ├── api-gateway/        # API Gateway module
│   │   ├── main.tf         # API Gateway resources
│   │   ├── variables.tf    # API Gateway variables
│   │   └── outputs.tf      # API Gateway outputs
│   └── xray/               # X-Ray tracing module
│       ├── main.tf         # X-Ray resources and IAM policies
│       ├── variables.tf    # X-Ray variables
│       └── outputs.tf      # X-Ray outputs
```

## ⚡ Swift Lambda Function Features

### Prime Checker Lambda
- **Runtime Implementation**: Uses AWS Lambda Runtime for Swift (provided.al2)
- **Prime Algorithm**: Efficient square root optimization with stride iteration
- **Edge Case Handling**: Properly handles 0, 1, 2, and negative numbers
- **Performance**: O(√n) time complexity with optimized loop structure

### Factorial Calculator Lambda
- **Runtime Implementation**: Uses AWS Lambda Runtime for Swift (provided.al2)
- **Factorial Algorithm**: Supports both standard and string-based calculation for large numbers
- **Large Number Support**: Handles factorials up to 1000! using string multiplication
- **Performance Tracking**: Returns calculation time for performance analysis
- **Input Validation**: Validates input range (0-1000) to prevent excessive computation

### Shared Features
- **Cross-Compilation**: Docker-based build for Amazon Linux compatibility
- **Static Linking**: Self-contained binary with minimal dependencies
- **Type Safety**: Swift's strong typing prevents runtime errors
- **Error Handling**: Robust JSON parsing and type checking
- **CORS Integration**: Built-in CORS headers for all responses including errors
- **X-Ray Tracing**: Active distributed tracing for performance monitoring
- **Comprehensive Logging**: Structured logging with Swift Logging framework
- **Request Correlation**: Request IDs for tracing requests across services
- **Performance Tracking**: Detailed timing information for optimization
- **CloudWatch Integration**: Automatic log group creation with retention policies

## 🔧 Infrastructure Details

### AWS Resources Created
- **API Gateway REST API**: Regional endpoint with custom domain support
- **API Gateway Resources**: `/prime` and `/factorial` paths
- **API Gateway Methods**: POST and OPTIONS (CORS) for both endpoints
- **API Gateway Integrations**: Lambda proxy integrations for both functions
- **API Gateway Deployment**: Automated deployment with triggers
- **API Gateway Stage**: Environment-specific stage (dev/prod) with X-Ray tracing
- **Prime Lambda Function**: Swift custom runtime (provided.al2) with X-Ray tracing
- **Factorial Lambda Function**: Swift custom runtime (provided.al2) with X-Ray tracing
- **IAM Roles**: Lambda execution roles with X-Ray permissions for both functions
- **IAM Policies**: Basic execution and X-Ray tracing permissions
- **Lambda Permissions**: API Gateway invoke permissions for both functions
- **CloudWatch Log Groups**: Dedicated log groups for both Lambda functions with 14-day retention
- **X-Ray Sampling Rules**: Configurable sampling rate for distributed tracing
- **CloudWatch Log Groups**: X-Ray trace storage and retention for both functions

### Security Features
- **Least Privilege IAM**: Minimal required permissions
- **No Hardcoded Secrets**: Uses AWS IAM for authentication
- **Input Validation**: Prevents injection attacks
- **Error Sanitization**: No sensitive data in error responses

## 📊 Monitoring and Observability

### X-Ray Distributed Tracing
- **End-to-End Visibility**: Track requests from API Gateway through Lambda execution
- **Performance Analysis**: Identify bottlenecks and latency issues
- **Error Tracking**: Detailed error analysis with stack traces
- **Service Map**: Visual representation of service dependencies
- **Sampling Configuration**: 10% sampling rate (configurable) to balance cost and visibility

### X-Ray Features
- **Request Tracing**: Complete request lifecycle from API Gateway to Lambda
- **Subsegment Analysis**: Detailed breakdown of Lambda execution phases
- **Error Analysis**: Automatic error detection and categorization
- **Performance Metrics**: Response times, throughput, and error rates
- **Custom Annotations**: Searchable metadata for filtering traces

### CloudWatch Integration
- **Lambda Logs**: Comprehensive execution logging with request IDs, timing, and error tracking
- **Log Groups**: Dedicated log groups for each Lambda function with 14-day retention
- **Structured Logging**: Swift Logging framework with metadata for filtering and analysis
- **API Gateway Logs**: Request/response logging available
- **X-Ray Traces**: Stored in dedicated CloudWatch log group
- **Metrics**: Built-in AWS metrics for performance monitoring
- **Alarms**: Can be configured for error rates and latency

### Lambda Execution Logging
Both Lambda functions include comprehensive logging:
- **Request Lifecycle**: Start, processing, and completion events
- **Performance Metrics**: Execution time and calculation time tracking
- **Input Validation**: Detailed logging of input validation and error cases
- **Algorithm Selection**: Logs which algorithm is used (standard vs string-based for factorial)
- **Result Metadata**: Result length, processing time, and success indicators
- **Error Tracking**: Detailed error messages with request correlation

### Accessing Logs and Monitoring Data
1. **CloudWatch Logs**: Navigate to CloudWatch > Log groups in AWS Console
   - `/aws/lambda/prime-checker`: Prime checker execution logs
   - `/aws/lambda/factorial-calculator`: Factorial calculator execution logs
   - `/aws/xray/prime-checker`: X-Ray traces for prime checker
   - `/aws/xray/factorial-calculator`: X-Ray traces for factorial calculator
2. **AWS Console**: Navigate to X-Ray service in AWS Console
3. **Service Map**: Visual overview of request flow and dependencies
4. **Traces**: Detailed individual request traces
5. **Analytics**: Query and filter traces by various criteria
6. **Log Insights**: Use CloudWatch Insights to query structured log data

### Performance Characteristics
- **Cold Start**: ~200-300ms for Swift Lambda (includes runtime initialization)
- **Warm Execution**: <1ms for prime calculations (native compiled performance)
- **Memory Usage**: 128MB allocated (adjustable, efficient due to compiled nature)
- **Timeout**: 30 seconds (configurable)
- **Binary Size**: ~21MB deployment package (includes Swift runtime)

## 🚀 Production Considerations

### Scaling
- **Lambda Concurrency**: Automatic scaling up to account limits
- **API Gateway**: Handles 10,000 requests per second by default
- **Regional Deployment**: Single region for low latency

### Cost Optimization
- **Pay-per-Use**: Only charged for actual requests
- **Minimal Memory**: 128MB for cost efficiency
- **Short Timeout**: 30 seconds to prevent runaway costs

### Security Enhancements
- **API Keys**: Can be added for access control
- **Rate Limiting**: API Gateway throttling available
- **WAF Integration**: Web Application Firewall support
- **VPC Integration**: Private subnet deployment option

## 🔄 Swift Migration

### Why Swift?
This project was migrated from Node.js to Swift to demonstrate:
- **Performance**: Native compiled code execution
- **Type Safety**: Compile-time error detection
- **Memory Efficiency**: Lower runtime memory footprint
- **AWS Integration**: Seamless integration with AWS Lambda Runtime

### Migration Details
- **Runtime Change**: From Node.js 18.x to Swift custom runtime (provided.al2)
- **Build Process**: Docker-based cross-compilation for Amazon Linux
- **API Compatibility**: Maintains identical REST API interface
- **Error Handling**: Enhanced with Swift's robust error handling
- **CORS Support**: Improved CORS implementation with proper OPTIONS handling

### Build Requirements
The Swift Lambda requires Docker for cross-compilation:
```bash
# Build the Swift Lambda function
cd modules/lambda/src
./build.sh

# This creates:
# - bootstrap: The Lambda runtime executable
# - lambda-deployment.zip: Ready-to-deploy package
```

### Development Workflow
1. **Modify Swift Code**: Edit function source in `modules/lambda-function/functions/{function-name}/src/Sources/`
2. **Update Dependencies**: Modify `Package.swift` if needed
3. **Build**: Run `./build.sh` in the function's src directory to create deployment package
4. **Deploy**: Run `terraform apply` to update Lambda function

### Adding New Lambda Functions
With the unified module, adding new Lambda functions is straightforward:

1. **Create Function Directory**: Add new directory under `modules/lambda-function/functions/`
2. **Add Source Code**: Create Swift source code and build script
3. **Update Root Configuration**: Add new module instance in `main.tf`:
   ```hcl
   module "new_lambda_function" {
     source = "./modules/lambda-function"
     
     function_name           = "new-function"
     description            = "Description of new function"
     deployment_package_path = "./modules/lambda-function/functions/new-function/function.zip"
     
     # Configure as needed
     aws_region             = var.aws_region
     enable_xray_tracing    = var.enable_xray_tracing
     log_retention_days     = var.log_retention_days
   }
   ```

## 🔄 CI/CD Integration

### GitHub Actions Workflows

This project includes automated CI/CD pipelines:

#### Terraform CI/CD Pipeline
- **On Pull Request**: Runs `terraform plan` and comments results on PR
- **On Merge to Main**: Automatically runs `terraform apply` to deploy infrastructure
- **Features**: Format checking, validation, plan review, automated deployment
- **Authentication**: Uses AWS OIDC for secure, keyless authentication

#### Swift Lambda Build Pipeline
- **Triggers**: Automatically builds when Swift code changes
- **Process**: Docker-based cross-compilation for Amazon Linux
- **Artifacts**: Deployment packages available for download
- **Functions**: Builds both prime-checker and factorial-calculator

#### Setup Instructions
1. **Configure AWS OIDC Provider** in your AWS account
2. **Create IAM Role** with trust policy for GitHub Actions
3. **Add `AWS_ROLE_ARN` secret** to GitHub repository settings
4. **Push changes** - workflows run automatically

See [`.github/workflows/README.md`](.github/workflows/README.md) for detailed setup instructions.

### Terraform State Management
- **Remote State**: Configure S3 backend for team collaboration
- **State Locking**: DynamoDB table for concurrent access protection
- **Workspaces**: Support for multiple environments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the [Issues](../../issues) page
2. Review CloudWatch logs for runtime errors
3. Verify AWS permissions and quotas
4. Test with curl commands provided above