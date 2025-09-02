#!/bin/bash

# Configuration
DOCKER_USERNAME="your-dockerhub-username"  # Replace with your actual Docker Hub username
IMAGE_NAME="xo-game"
VERSION="1.0.0"

echo "🐳 Pushing XO Game image to Docker Hub..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if user has set their Docker Hub username
if [ "$DOCKER_USERNAME" = "your-dockerhub-username" ]; then
    echo "❌ Please edit this script and set your Docker Hub username in DOCKER_USERNAME variable"
    echo "   Current value: $DOCKER_USERNAME"
    exit 1
fi

echo "📦 Building Docker image..."
docker build -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .

if [ $? -ne 0 ]; then
    echo "❌ Failed to build Docker image"
    exit 1
fi

echo "🏷️  Tagging image for Docker Hub..."
docker tag $IMAGE_NAME:$VERSION $DOCKER_USERNAME/$IMAGE_NAME:$VERSION
docker tag $IMAGE_NAME:latest $DOCKER_USERNAME/$IMAGE_NAME:latest

echo "🔐 Logging into Docker Hub..."
echo "Please enter your Docker Hub credentials when prompted:"
docker login

if [ $? -ne 0 ]; then
    echo "❌ Failed to login to Docker Hub"
    exit 1
fi

echo "📤 Pushing image to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:$VERSION
docker push $DOCKER_USERNAME/$IMAGE_NAME:latest

if [ $? -eq 0 ]; then
    echo "✅ Successfully pushed image to Docker Hub!"
    echo "🌐 Your image is now available at:"
    echo "   https://hub.docker.com/r/$DOCKER_USERNAME/$IMAGE_NAME"
    echo ""
    echo "📋 To pull the image on another machine:"
    echo "   docker pull $DOCKER_USERNAME/$IMAGE_NAME:latest"
    echo "   docker pull $DOCKER_USERNAME/$IMAGE_NAME:$VERSION"
else
    echo "❌ Failed to push image to Docker Hub"
    exit 1
fi
