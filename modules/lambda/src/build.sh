#!/bin/bash

# Build script for Swift Lambda function
set -e

echo "Building Swift Lambda function..."

# Build the Swift package for Amazon Linux 2
docker run --rm -v "$PWD":/workspace -w /workspace swift:5.7-amazonlinux2 bash -c "
    yum update -y && \
    yum install -y zip && \
    swift build --product PrimeChecker -c release && \
    cp .build/release/PrimeChecker bootstrap && \
    zip lambda-deployment.zip bootstrap
"

echo "Build complete. Deployment package: lambda-deployment.zip"