#!/bin/bash

# Terraform Setup Script for XO Game
echo "🚀 Setting up Terraform for XO Game Infrastructure"
echo "=================================================="

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Installing..."
    
    # Install Terraform
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
else
    echo "✅ Terraform is already installed"
fi

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ kubectl not configured or cluster not accessible"
    echo "Please ensure your Kubernetes cluster is running and kubectl is configured"
    exit 1
else
    echo "✅ Kubernetes cluster is accessible"
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📋 Planning Terraform deployment..."
terraform plan

echo ""
echo "🎯 Ready to deploy! Run the following commands:"
echo "   terraform apply    # Deploy the infrastructure"
echo "   terraform destroy  # Remove the infrastructure"
echo ""
echo "📊 After deployment, check status with:"
echo "   kubectl get pods -n xo-game"
echo "   kubectl get hpa -n xo-game"
