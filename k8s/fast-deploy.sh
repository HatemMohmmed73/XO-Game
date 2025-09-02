#!/bin/bash

echo "🚀 Fast Deploy - XO Game with Data on All Nodes"
echo "================================================"
echo ""

# Clean up any stuck resources
echo "🧹 Cleaning up stuck resources..."
kubectl delete deployment xo-game-stress-test -n xo-game --ignore-not-found=true
kubectl delete pvc xo-game-shared-data -n xo-game --ignore-not-found=true
kubectl delete pv xo-game-shared-storage --ignore-not-found=true

# Wait for cleanup
sleep 5

echo "📦 Creating simple shared storage..."
kubectl apply -f k8s/shared-storage.yaml

echo "🐘 Starting PostgreSQL cluster..."
kubectl apply -f k8s/postgres-cluster-deployment.yaml
kubectl apply -f k8s/postgres-cluster-service.yaml

echo "⏳ Waiting for database (max 60 seconds)..."
kubectl wait --for=condition=ready pod -l app=xo-game,component=postgres-cluster --timeout=60s -n xo-game

echo "🎮 Deploying app with 4 replicas..."
kubectl apply -f k8s/stress-test-deployment.yaml

echo "⏳ Waiting for app pods (max 60 seconds)..."
kubectl wait --for=condition=ready pod -l app=xo-game,test=stress --timeout=60s -n xo-game

echo "🔄 Setting up auto-scaling..."
kubectl apply -f k8s/hpa.yaml

echo "🌐 Creating service..."
kubectl apply -f k8s/stress-test-service.yaml

echo ""
echo "✅ Fast deployment complete!"
echo ""
echo "📊 Status:"
kubectl get pods -n xo-game --no-headers | wc -l | tr -d ' '
echo " pods running"
echo ""
echo "🔗 Data Distribution:"
echo "   • All replicas share the same storage volume"
echo "   • Data persists across all nodes"
echo "   • Fast deployment with simple storage"
echo ""
echo "🧪 Test it now:"
echo "   kubectl get pods -n xo-game"
echo "   kubectl get pvc -n xo-game"
