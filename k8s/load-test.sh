#!/bin/bash

echo "🚀 XO Game - Load Testing Script"
echo "================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_DURATION=300  # 5 minutes
CONCURRENT_USERS=50
RAMP_UP_TIME=30

# Function to check if Kubernetes is accessible
check_k8s() {
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✅ Kubernetes is accessible${NC}"
        return 0
    else
        echo -e "${RED}❌ Kubernetes is not accessible${NC}"
        return 1
    fi
}

# Function to get app service IP
get_service_ip() {
    SERVICE_IP=$(kubectl get service xo-game-stress-test-service -n xo-game -o jsonpath='{.spec.clusterIP}' 2>/dev/null)
    if [ -z "$SERVICE_IP" ]; then
        echo -e "${RED}❌ Could not get service IP${NC}"
        return 1
    fi
    echo -e "${GREEN}🎯 Service IP: $SERVICE_IP${NC}"
    return 0
}

# Function to show current status
show_status() {
    echo -e "${BLUE}📊 Current System Status:${NC}"
    echo "   Pods: $(kubectl get pods -n xo-game -l app=xo-game,test=stress --no-headers 2>/dev/null | wc -l | tr -d ' ') running"
    echo "   HPA: $(kubectl get hpa xo-game-hpa -n xo-game -o jsonpath='{.status.currentReplicas}' 2>/dev/null) current replicas"
    echo "   Database: $(kubectl get pods -n xo-game -l app=xo-game,component=postgres-cluster --no-headers 2>/dev/null | wc -l | tr -d ' ') nodes"
    echo ""
}

# Function to run load test with hey
run_hey_test() {
    echo -e "${BLUE}🔥 Running load test with hey...${NC}"
    
    if ! command -v hey &> /dev/null; then
        echo -e "${YELLOW}📦 Installing hey load testing tool...${NC}"
        curl -s https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 -o hey
        chmod +x hey
        sudo mv hey /usr/local/bin/
    fi
    
    SERVICE_IP=$(kubectl get service xo-game-stress-test-service -n xo-game -o jsonpath='{.spec.clusterIP}')
    
    echo -e "${GREEN}🚀 Starting load test:${NC}"
    echo "   • Duration: ${TEST_DURATION}s"
    echo "   • Concurrent users: ${CONCURRENT_USERS}"
    echo "   • Target: http://$SERVICE_IP:8080"
    echo ""
    
    hey -z ${TEST_DURATION}s -c ${CONCURRENT_USERS} -t 0 -m GET "http://$SERVICE_IP:8080/"
}

# Function to run load test with curl
run_curl_test() {
    echo -e "${BLUE}🔥 Running load test with curl...${NC}"
    
    SERVICE_IP=$(kubectl get service xo-game-stress-test-service -n xo-game -o jsonpath='{.spec.clusterIP}')
    
    echo -e "${GREEN}🚀 Starting load test:${NC}"
    echo "   • Duration: ${TEST_DURATION}s"
    echo "   • Concurrent users: ${CONCURRENT_USERS}"
    echo "   • Target: http://$SERVICE_IP:8080"
    echo ""
    
    # Run load test in background
    (
        for i in {1..300}; do
            curl -s "http://$SERVICE_IP:8080/health" > /dev/null 2>&1 &
            curl -s "http://$SERVICE_IP:8080/" > /dev/null 2>&1 &
            sleep 1
            
            if [ $((i % 30)) -eq 0 ]; then
                echo "   ⏱️  Load test running... $((i/60))m $((i%60))s elapsed"
            fi
        done
        echo "   ✅ Load test completed!"
    ) &
    
    LOAD_PID=$!
    
    echo "📊 Load test running in background (PID: $LOAD_PID)"
    echo "   Press Enter to stop monitoring..."
    read -p ""
    
    echo "🛑 Stopping load test..."
    kill $LOAD_PID 2>/dev/null
}

# Function to monitor system during load test
monitor_system() {
    echo -e "${BLUE}📊 Monitoring system during load test...${NC}"
    echo "   Press Ctrl+C to stop monitoring"
    echo ""
    
    trap "echo ''; echo '🛑 Monitoring stopped'; exit 0" INT
    
    while true; do
        clear
        echo "🚀 XO Game - System Monitor"
        echo "============================"
        echo ""
        
        show_status
        
        echo "📊 Pod Distribution:"
        kubectl get pods -n xo-game -l app=xo-game,test=stress -o wide --no-headers 2>/dev/null | while read line; do
            echo "   $line"
        done
        
        echo ""
        echo "💾 Database Status:"
        kubectl get pods -n xo-game -l app=xo-game,component=postgres-cluster --no-headers 2>/dev/null | while read line; do
            echo "   $line"
        done
        
        echo ""
        echo "🔄 Auto-scaling Status:"
        kubectl get hpa xo-game-hpa -n xo-game --no-headers 2>/dev/null | while read line; do
            echo "   $line"
        done
        
        echo ""
        echo "⏱️  Monitoring... Press Ctrl+C to stop"
        
        sleep 5
    done
}

# Function to scale replicas
scale_replicas() {
    echo -e "${BLUE}📈 Scaling replicas...${NC}"
    echo "Current replicas: $(kubectl get deployment xo-game-stress-test -n xo-game -o jsonpath='{.spec.replicas}')"
    echo ""
    
    read -p "Enter new number of replicas (4-16): " new_replicas
    
    if [[ "$new_replicas" =~ ^[4-9]$|^1[0-6]$ ]]; then
        kubectl scale deployment xo-game-stress-test --replicas=$new_replicas -n xo-game
        echo -e "${GREEN}✅ Scaled to $new_replicas replicas${NC}"
    else
        echo -e "${RED}❌ Invalid number. Must be 4-16${NC}"
    fi
}

# Main menu
while true; do
    clear
    echo "🚀 XO Game - Load Testing Menu"
    echo "================================"
    echo ""
    echo "1. Show system status"
    echo "2. Run load test with hey"
    echo "3. Run load test with curl"
    echo "4. Monitor system in real-time"
    echo "5. Scale replicas"
    echo "6. Exit"
    echo ""
    
    read -p "Choose an option (1-6): " choice
    
    case $choice in
        1)
            echo ""
            show_status
            read -p "Press Enter to continue..."
            ;;
        2)
            echo ""
            if check_k8s && get_service_ip; then
                run_hey_test
            fi
            read -p "Press Enter to continue..."
            ;;
        3)
            echo ""
            if check_k8s && get_service_ip; then
                run_curl_test
            fi
            read -p "Press Enter to continue..."
            ;;
        4)
            echo ""
            if check_k8s; then
                monitor_system
            fi
            ;;
        5)
            echo ""
            if check_k8s; then
                scale_replicas
            fi
            read -p "Press Enter to continue..."
            ;;
        6)
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Invalid option${NC}"
            read -p "Press Enter to continue..."
            ;;
    esac
done
