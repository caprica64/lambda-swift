# GitHub Actions Workflows

This directory contains CI/CD workflows for the Lambda Swift project.

## Workflows

### 1. Terraform CI/CD (`terraform.yml`)

Automates Terraform infrastructure deployment with the following features:

#### Triggers
- **Pull Request**: Runs `terraform plan` and comments the plan on the PR
- **Push to main**: Runs `terraform apply` to deploy infrastructure

#### Steps
1. **Format Check**: Validates Terraform code formatting
2. **Initialize**: Sets up Terraform backend and providers
3. **Validate**: Checks Terraform configuration syntax
4. **Plan**: Generates execution plan (on PR)
5. **Comment**: Posts plan results to PR for review
6. **Apply**: Deploys infrastructure (on merge to main)

#### Required Secrets
- `AWS_ROLE_ARN`: ARN of the IAM role for GitHub Actions OIDC authentication

#### AWS Authentication
Uses OpenID Connect (OIDC) for secure, keyless authentication to AWS. No long-lived credentials needed.

#### Setup Instructions

1. **Create IAM OIDC Provider in AWS**:
   ```bash
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
   ```

2. **Create IAM Role with Trust Policy**:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
         },
         "Action": "sts:AssumeRoleWithWebIdentity",
         "Condition": {
           "StringEquals": {
             "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
           },
           "StringLike": {
             "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/YOUR_REPO_NAME:*"
           }
         }
       }
     ]
   }
   ```

3. **Attach Required Policies to Role**:
   - `AWSLambdaFullAccess`
   - `IAMFullAccess`
   - `AmazonAPIGatewayAdministrator`
   - `CloudWatchLogsFullAccess`
   - `AWSXRayFullAccess`

4. **Add Secret to GitHub Repository**:
   - Go to repository Settings → Secrets and variables → Actions
   - Add new secret: `AWS_ROLE_ARN` with value `arn:aws:iam::YOUR_ACCOUNT_ID:role/YOUR_ROLE_NAME`

### 2. Build Swift Lambda Functions (`build-lambda.yml`)

Builds Swift Lambda functions using Docker for Amazon Linux compatibility.

#### Triggers
- **Push to main**: When Swift source files change
- **Pull Request**: When Swift source files change
- **Manual**: Via workflow_dispatch

#### Jobs
1. **Build Prime Checker**: Compiles prime checker Lambda function
2. **Build Factorial Calculator**: Compiles factorial calculator Lambda function

#### Artifacts
- Deployment packages are uploaded as artifacts
- Retained for 7 days
- Can be downloaded for manual deployment

#### Build Process
Each job:
1. Checks out code
2. Sets up Docker Buildx
3. Runs `build.sh` script (Docker-based cross-compilation)
4. Uploads resulting ZIP file as artifact

## Workflow Best Practices

### Pull Request Workflow
1. Create feature branch
2. Make changes to Terraform or Swift code
3. Push to GitHub
4. GitHub Actions runs:
   - Terraform format check
   - Terraform plan (commented on PR)
   - Swift Lambda builds (if code changed)
5. Review plan in PR comments
6. Merge when approved

### Deployment Workflow
1. Merge PR to main branch
2. GitHub Actions automatically:
   - Builds Lambda functions (if needed)
   - Runs `terraform apply`
   - Deploys infrastructure to AWS

## Security Considerations

- **OIDC Authentication**: No long-lived AWS credentials stored in GitHub
- **Least Privilege**: IAM role has only required permissions
- **Branch Protection**: Only main branch can deploy
- **PR Reviews**: Plan is visible before apply
- **Audit Trail**: All deployments logged in GitHub Actions

## Troubleshooting

### Terraform Init Fails
- Check AWS credentials and role permissions
- Verify Terraform backend configuration

### Terraform Plan Fails
- Review validation errors in workflow logs
- Check for syntax errors in `.tf` files

### Terraform Apply Fails
- Review error messages in workflow logs
- Check AWS service quotas and limits
- Verify IAM permissions

### Lambda Build Fails
- Ensure Docker is available in runner
- Check Swift syntax errors
- Verify `build.sh` script has execute permissions

## Local Testing

Before pushing, test locally:

```bash
# Format Terraform code
terraform fmt -recursive

# Validate Terraform
terraform init
terraform validate

# Build Lambda functions
cd modules/lambda-function/functions/prime-checker/src
./build.sh
cd ../../../factorial-calculator/src
./build.sh
```

## Monitoring

- View workflow runs: Repository → Actions tab
- Check logs for each step
- Download artifacts from completed runs
- Review PR comments for plan output
