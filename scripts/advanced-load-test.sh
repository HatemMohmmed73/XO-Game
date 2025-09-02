#!/bin/bash

# XO Game - Advanced Load Testing Suite
# Comprehensive testing with multiple scenarios and detailed reporting

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
NAMESPACE="xo-game"
APP_LABEL="app=xo-game,test=stress"
DB_LABEL="app=xo-game,component=postgres-cluster"
RESULTS_DIR="./load-test-results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Test scenarios
declare -A SCENARIOS=(
    ["light"]="10 60 1"
    ["medium"]="50 300 2"
    ["heavy"]="100 600 5"
    ["extreme"]="200 900 10"
)

# Function to print header
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  XO Game Load Testing Suite${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Checking prerequisites...${NC}"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl not found${NC}"
        exit 1
    fi
    
    # Check if cluster is accessible
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Kubernetes cluster not accessible${NC}"
        exit 1
    fi
    
    # Check if namespace exists
    if ! kubectl get namespace $NAMESPACE &> /dev/null; then
        echo -e "${RED}❌ Namespace $NAMESPACE not found${NC}"
        exit 1
    fi
    
    # Check if app pods are running
    APP_PODS=$(kubectl get pods -n $NAMESPACE -l $APP_LABEL --no-headers 2>/dev/null | wc -l)
    if [ $APP_PODS -eq 0 ]; then
        echo -e "${RED}❌ No app pods found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
    echo "   • Kubernetes cluster: accessible"
    echo "   • Namespace: $NAMESPACE"
    echo "   • App pods: $APP_PODS running"
    echo ""
}

# Function to get system status
get_system_status() {
    echo -e "${CYAN}📊 System Status:${NC}"
    
    # Pod status
    echo "   Pods:"
    kubectl get pods -n $NAMESPACE -l $APP_LABEL --no-headers | while read line; do
        echo "     $line"
    done
    
    # Service status
    echo "   Services:"
    kubectl get services -n $NAMESPACE --no-headers | while read line; do
        echo "     $line"
    done
    
    # HPA status
    echo "   HPA:"
    kubectl get hpa -n $NAMESPACE --no-headers | while read line; do
        echo "     $line"
    done
    
    echo ""
}

# Function to install hey if not present
install_hey() {
    if ! command -v hey &> /dev/null; then
        echo -e "${YELLOW}📦 Installing hey load testing tool...${NC}"
        curl -s https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 -o hey
        chmod +x hey
        sudo mv hey /usr/local/bin/
        echo -e "${GREEN}✅ hey installed successfully${NC}"
    fi
}

# Function to get service endpoint
get_service_endpoint() {
    SERVICE_IP=$(kubectl get service xo-game-stress-test-service -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    if [ -z "$SERVICE_IP" ]; then
        echo -e "${RED}❌ Could not get service IP${NC}"
        exit 1
    fi
    echo "http://$SERVICE_IP:8080"
}

# Function to run load test scenario
run_scenario() {
    local scenario_name=$1
    local concurrent_users=$2
    local duration=$3
    local ramp_up=$4
    
    echo -e "${PURPLE}🚀 Running scenario: $scenario_name${NC}"
    echo "   • Concurrent users: $concurrent_users"
    echo "   • Duration: ${duration}s"
    echo "   • Ramp up: ${ramp_up}s"
    echo ""
    
    local endpoint=$(get_service_endpoint)
    local results_file="$RESULTS_DIR/${scenario_name}_${TIMESTAMP}.txt"
    
    # Create results directory
    mkdir -p $RESULTS_DIR
    
    # Run hey load test
    hey -z ${duration}s -c $concurrent_users -t 0 -m GET "$endpoint/" > $results_file 2>&1
    
    # Parse results
    local total_requests=$(grep "Total:" $results_file | awk '{print $2}')
    local requests_per_sec=$(grep "Requests/sec:" $results_file | awk '{print $2}')
    local avg_latency=$(grep "Average:" $results_file | awk '{print $2}')
    local slowest=$(grep "Slowest:" $results_file | awk '{print $2}')
    local fastest=$(grep "Fastest:" $results_file | awk '{print $2}')
    
    echo -e "${GREEN}📈 Results for $scenario_name:${NC}"
    echo "   • Total requests: $total_requests"
    echo "   • Requests/sec: $requests_per_sec"
    echo "   • Average latency: $avg_latency"
    echo "   • Slowest request: $slowest"
    echo "   • Fastest request: $fastest"
    echo ""
    
    # Check for errors
    local error_count=$(grep -c "Error distribution:" $results_file || echo "0")
    if [ $error_count -gt 0 ]; then
        echo -e "${RED}⚠️  Errors detected in $scenario_name${NC}"
        grep -A 10 "Error distribution:" $results_file
        echo ""
    fi
}

# Function to monitor during test
monitor_during_test() {
    local duration=$1
    local interval=10
    
    echo -e "${CYAN}📊 Monitoring system during test...${NC}"
    
    for ((i=0; i<duration; i+=interval)); do
        echo "   Time: ${i}s"
        
        # Pod count
        local pod_count=$(kubectl get pods -n $NAMESPACE -l $APP_LABEL --no-headers | wc -l)
        echo "     Pods: $pod_count"
        
        # HPA status
        local current_replicas=$(kubectl get hpa xo-game-hpa -n $NAMESPACE -o jsonpath='{.status.currentReplicas}' 2>/dev/null || echo "N/A")
        echo "     HPA replicas: $current_replicas"
        
        # CPU usage (if metrics available)
        if kubectl top pods -n $NAMESPACE -l $APP_LABEL &> /dev/null; then
            echo "     CPU usage:"
            kubectl top pods -n $NAMESPACE -l $APP_LABEL --no-headers | while read line; do
                echo "       $line"
            done
        fi
        
        echo ""
        sleep $interval
    done
}

# Function to run comprehensive test suite
run_comprehensive_test() {
    echo -e "${BLUE}🎯 Running comprehensive test suite...${NC}"
    echo ""
    
    for scenario in "${!SCENARIOS[@]}"; do
        IFS=' ' read -r users duration ramp_up <<< "${SCENARIOS[$scenario]}"
        
        # Start monitoring in background
        monitor_during_test $duration &
        MONITOR_PID=$!
        
        # Run the scenario
        run_scenario $scenario $users $duration $ramp_up
        
        # Stop monitoring
        kill $MONITOR_PID 2>/dev/null || true
        
        # Wait between scenarios
        if [ "$scenario" != "extreme" ]; then
            echo -e "${YELLOW}⏳ Waiting 30 seconds before next scenario...${NC}"
            sleep 30
        fi
    done
}

# Function to generate report
generate_report() {
    echo -e "${BLUE}📋 Generating comprehensive report...${NC}"
    
    local report_file="$RESULTS_DIR/load_test_report_${TIMESTAMP}.md"
    
    cat > $report_file << EOF
# XO Game Load Testing Report

**Date:** $(date)
**Namespace:** $NAMESPACE
**Test Duration:** $(date -d @$(($(date +%s) - $(date -d "$TIMESTAMP" +%s))) -u +%H:%M:%S)

## System Configuration

- **App Pods:** $(kubectl get pods -n $NAMESPACE -l $APP_LABEL --no-headers | wc -l)
- **Database Pods:** $(kubectl get pods -n $NAMESPACE -l $DB_LABEL --no-headers | wc -l)
- **HPA Min/Max:** $(kubectl get hpa xo-game-hpa -n $NAMESPACE -o jsonpath='{.spec.minReplicas}/{.spec.maxReplicas}' 2>/dev/null || echo "N/A")

## Test Results

EOF

    # Add results for each scenario
    for scenario in "${!SCENARIOS[@]}"; do
        local results_file="$RESULTS_DIR/${scenario}_${TIMESTAMP}.txt"
        if [ -f "$results_file" ]; then
            echo "### $scenario Scenario" >> $report_file
            echo '```' >> $report_file
            cat $results_file >> $report_file
            echo '```' >> $report_file
            echo "" >> $report_file
        fi
    done
    
    echo -e "${GREEN}✅ Report generated: $report_file${NC}"
}

# Function to cleanup
cleanup() {
    echo -e "${YELLOW}🧹 Cleaning up...${NC}"
    # Kill any background processes
    jobs -p | xargs -r kill
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Main execution
main() {
    print_header
    
    # Set trap for cleanup
    trap cleanup EXIT
    
    # Check prerequisites
    check_prerequisites
    
    # Install hey if needed
    install_hey
    
    # Get initial system status
    get_system_status
    
    # Run comprehensive test suite
    run_comprehensive_test
    
    # Generate report
    generate_report
    
    echo -e "${GREEN}🎉 Load testing completed successfully!${NC}"
    echo -e "${CYAN}📁 Results saved in: $RESULTS_DIR${NC}"
}

# Run main function
main "$@"
