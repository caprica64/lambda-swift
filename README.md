# Prime Checker API

A Terraform-based AWS infrastructure that creates an API Gateway connected to a Lambda function written in Swift to check if numbers are prime.

## Architecture

- **API Gateway**: REST API with `/prime` endpoint
- **Lambda Function**: Swift-based function that determines if a number is prime
- **Modular Structure**: Organized using Terraform modules

## API Usage

### Endpoint
```
POST /prime
```

### Request Body
```json
{
  "number": 17
}
```

### Response
```json
{
  "number": 17,
  "isPrime": true,
  "message": "17 is a prime number"
}
```

## Deployment

1. **Prerequisites**:
   - AWS CLI configured
   - Terraform installed
   - Docker (for building Swift Lambda)

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Build Swift Lambda** (first time only):
   ```bash
   cd modules/lambda/src
   chmod +x build.sh
   ./build.sh
   ```

4. **Deploy infrastructure**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Testing

After deployment, test the API:

```bash
curl -X POST https://your-api-id.execute-api.region.amazonaws.com/dev/prime \
  -H "Content-Type: application/json" \
  -d '{"number": 17}'
```

## Module Structure

```
├── main.tf                 # Root configuration
├── variables.tf           # Root variables
├── outputs.tf            # Root outputs
├── modules/
│   ├── lambda/           # Lambda module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── src/         # Swift source code
│   └── api-gateway/     # API Gateway module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
```

## Swift Lambda Function

The Lambda function uses the Swift AWS Lambda Runtime and implements an efficient prime number algorithm with optimizations for performance.