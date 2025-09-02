#!/bin/bash

# XO Game - Master Deployment Script
# Deploys everything: Infrastructure, Monitoring, CI/CD, and Testing

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🚀 XO Game - Complete Infrastructure Deployment${NC}"
echo -e "${BLUE}===============================================${NC}"
echo ""

# Function to print section header
print_section() {
    echo -e "${PURPLE}📋 $1${NC}"
    echo -e "${PURPLE}$(printf '=%.0s' {1..50})${NC}"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl not found${NC}"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker not found${NC}"
        exit 1
    fi
    
    # Check if Kubernetes cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Kubernetes cluster not accessible${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ All prerequisites met${NC}"
    echo ""
}

# Function to build and push Docker image
build_and_push_image() {
    print_section "Building and Pushing Docker Image"
    
    echo -e "${YELLOW}🔨 Building Docker image...${NC}"
    docker build -t xo-game:latest .
    
    echo -e "${YELLOW}📤 Loading image into Kubernetes...${NC}"
    if command -v minikube &> /dev/null; then
        minikube image load xo-game:latest
    elif command -v kind &> /dev/null; then
        kind load docker-image xo-game:latest
    elif command -v k3d &> /dev/null; then
        k3d image import xo-game:latest
    else
        echo -e "${YELLOW}⚠️  No local cluster detected. Make sure to push to registry.${NC}"
    fi
    
    echo -e "${GREEN}✅ Docker image ready${NC}"
    echo ""
}

# Function to deploy with Terraform
deploy_with_terraform() {
    print_section "Deploying with Terraform (Infrastructure as Code)"
    
    if [ -d "terraform" ]; then
        cd terraform
        
        echo -e "${YELLOW}📦 Initializing Terraform...${NC}"
        terraform init
        
        echo -e "${YELLOW}📋 Planning deployment...${NC}"
        terraform plan
        
        echo -e "${YELLOW}🚀 Applying Terraform configuration...${NC}"
        terraform apply -auto-approve
        
        echo -e "${GREEN}✅ Terraform deployment completed${NC}"
        cd ..
    else
        echo -e "${YELLOW}⚠️  Terraform directory not found, skipping...${NC}"
    fi
    
    echo ""
}

# Function to deploy with scripts
deploy_with_scripts() {
    print_section "Deploying with Kubernetes Scripts"
    
    echo -e "${YELLOW}🚀 Running fast deployment...${NC}"
    ./k8s/fast-deploy.sh
    
    echo -e "${GREEN}✅ Kubernetes deployment completed${NC}"
    echo ""
}

# Function to setup monitoring
setup_monitoring() {
    print_section "Setting up Monitoring and Observability"
    
    # Create monitoring namespace
    kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Deploy Prometheus (if available)
    if [ -f "monitoring/prometheus-config.yaml" ]; then
        echo -e "${YELLOW}📊 Deploying Prometheus...${NC}"
        kubectl apply -f monitoring/prometheus-config.yaml
    fi
    
    # Deploy Grafana (if available)
    if [ -f "monitoring/grafana-dashboard.json" ]; then
        echo -e "${YELLOW}📈 Grafana dashboard configuration ready${NC}"
    fi
    
    echo -e "${GREEN}✅ Monitoring setup completed${NC}"
    echo ""
}

# Function to run initial tests
run_initial_tests() {
    print_section "Running Initial Tests"
    
    echo -e "${YELLOW}⏳ Waiting for all pods to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=xo-game,test=stress --timeout=300s -n xo-game
    
    echo -e "${YELLOW}🧪 Running health checks...${NC}"
    SERVICE_IP=$(kubectl get service xo-game-stress-test-service -n xo-game -o jsonpath='{.spec.clusterIP}')
    
    if curl -f "http://$SERVICE_IP:8080/health" &> /dev/null; then
        echo -e "${GREEN}✅ Health check passed${NC}"
    else
        echo -e "${RED}❌ Health check failed${NC}"
    fi
    
    echo -e "${GREEN}✅ Initial tests completed${NC}"
    echo ""
}

# Function to show final status
show_final_status() {
    print_section "Final System Status"
    
    echo -e "${CYAN}📊 Pod Status:${NC}"
    kubectl get pods -n xo-game -o wide
    
    echo ""
    echo -e "${CYAN}🌐 Services:${NC}"
    kubectl get services -n xo-game
    
    echo ""
    echo -e "${CYAN}📈 Auto-scaling:${NC}"
    kubectl get hpa -n xo-game
    
    echo ""
    echo -e "${CYAN}💾 Storage:${NC}"
    kubectl get pvc -n xo-game
    
    echo ""
}

# Function to show next steps
show_next_steps() {
    print_section "Next Steps"
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Available commands:${NC}"
    echo "   • Load testing: ./k8s/load-test.sh"
    echo "   • Simple stress test: ./k8s/simple-stress-test.sh"
    echo "   • Advanced load testing: ./scripts/advanced-load-test.sh"
    echo "   • Monitor system: kubectl get pods -n xo-game"
    echo "   • View logs: kubectl logs -l app=xo-game,test=stress -n xo-game"
    echo ""
    echo -e "${YELLOW}🔧 Management commands:${NC}"
    echo "   • Scale replicas: kubectl scale deployment xo-game-stress-test --replicas=10 -n xo-game"
    echo "   • Update image: kubectl set image deployment/xo-game-stress-test xo-game-app=xo-game:new-tag -n xo-game"
    echo "   • Delete everything: kubectl delete namespace xo-game"
    echo ""
    echo -e "${YELLOW}📊 Monitoring:${NC}"
    echo "   • Prometheus: kubectl port-forward -n monitoring svc/prometheus 9090:9090"
    echo "   • Grafana: kubectl port-forward -n monitoring svc/grafana 3000:3000"
    echo ""
}

# Main execution
main() {
    # Check prerequisites
    check_prerequisites
    
    # Build and push image
    build_and_push_image
    
    # Deploy infrastructure
    if [ "$1" = "terraform" ]; then
        deploy_with_terraform
    else
        deploy_with_scripts
    fi
    
    # Setup monitoring
    setup_monitoring
    
    # Run initial tests
    run_initial_tests
    
    # Show final status
    show_final_status
    
    # Show next steps
    show_next_steps
}

# Run main function with arguments
main "$@"
