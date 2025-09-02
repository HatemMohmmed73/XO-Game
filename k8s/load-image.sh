#!/bin/bash

echo "🐳 Loading Docker image into Kubernetes cluster..."

# Check if we're using minikube
if command -v minikube &> /dev/null; then
    echo "📦 Using minikube - loading image..."
    minikube image load xo-game:latest
    echo "✅ Image loaded into minikube"
elif command -v kind &> /dev/null; then
    echo "📦 Using kind - loading image..."
    kind load docker-image xo-game:latest
    echo "✅ Image loaded into kind cluster"
elif command -v k3d &> /dev/null; then
    echo "📦 Using k3d - loading image..."
    k3d image import xo-game:latest
    echo "✅ Image loaded into k3d cluster"
else
    echo "⚠️  No known local cluster tool detected"
    echo "🔧 Please manually load the image into your cluster or change imagePullPolicy to Always"
fi

