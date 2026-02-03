#!/bin/bash

# Build script for Swift Lambda function
set -e

echo "Building Swift Lambda function..."

# Clean previous builds
rm -f bootstrap lambda-deployment.zip

# Build the Swift package for Amazon Linux 2 x86_64 with static linking
docker run --rm --platform linux/amd64 -v "$PWD":/workspace -w /workspace swift:5.9-amazonlinux2 bash -c "
    yum update -y && \
    yum install -y zip && \
    swift build --product PrimeChecker -c release --static-swift-stdlib && \
    cp .build/release/PrimeChecker bootstrap && \
    zip lambda-deployment.zip bootstrap
"

echo "Build complete. Deployment package: lambda-deployment.zip"