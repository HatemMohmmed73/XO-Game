# XO Game Kubernetes Deployment

This directory contains the Kubernetes configuration files for deploying the XO Game application.

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- Kubernetes cluster (minikube, kind, or k3d)
- kubectl configured

### 1. Build Docker Image
```bash
# From the project root
docker build -t xo-game:latest .
```

### 2. Load Image into Cluster
```bash
# For minikube
minikube image load xo-game:latest

# For kind
kind load docker-image xo-game:latest

# For k3d
k3d image import xo-game:latest
```

### 3. Deploy to Kubernetes
```bash
cd k8s
./deploy.sh
```

## 📁 Configuration Files

- **`app-deployment.yaml`** - XO Game application deployment
- **`postgres-deployment.yaml`** - PostgreSQL database deployment
- **`app-service.yaml`** - Application service (NodePort)
- **`postgres-service.yaml`** - Database service (ClusterIP)
- **`postgres-data-persistentvolumeclaim.yaml`** - Database storage

## 🌐 Accessing the Application

### Option 1: NodePort (External Access)
```bash
# Get minikube IP
minikube ip

# Access via NodePort (port 30081)
curl http://<minikube-ip>:30081/health
```

### Option 2: Port Forward (Recommended for Development)
```bash
kubectl port-forward service/xo-game-app-service 8080:8080
# Then access at http://localhost:8080
```

### Option 3: LoadBalancer (if available)
```bash
kubectl patch service xo-game-app-service -p '{"spec":{"type":"LoadBalancer"}}'
```

## 📊 Monitoring

### Check Pod Status
```bash
kubectl get pods -l app=xo-game
```

### Check Services
```bash
kubectl get services -l app=xo-game
```

### View Logs
```bash
# App logs
kubectl logs -l app=xo-game,component=app

# Database logs
kubectl logs -l app=xo-game,component=postgres
```

### Check Database Connection
```bash
kubectl run test-curl --image=curlimages/curl -i --rm --restart=Never -- curl -s http://xo-game-app-service:8080/health
```

## 🔧 Troubleshooting

### Common Issues

1. **Image Pull Errors**
   - Ensure image is loaded into cluster: `./load-image.sh`
   - Check image name matches deployment

2. **Database Connection Issues**
   - Verify PostgreSQL pod is running: `kubectl get pods -l app=xo-game,component=postgres`
   - Check service IP resolution: `kubectl get endpoints xo-game-postgres-service`

3. **Port Access Issues**
   - Use port-forward for development: `kubectl port-forward service/xo-game-app-service 8080:8080`
   - Check NodePort availability: `kubectl get services xo-game-app-service`

### Reset Everything
```bash
kubectl delete namespace xo-game
```

## 📈 Scaling

### Scale Application
```bash
kubectl scale deployment xo-game-app --replicas=3
```

### Scale Database (Not Recommended)
```bash
# PostgreSQL should typically run as single instance
kubectl scale deployment xo-game-postgres --replicas=1
```

## 🔒 Security Notes

- Database credentials are hardcoded (use secrets in production)
- No ingress/network policies configured
- Consider using Helm charts for production deployments

## 📝 Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| DB_HOST | xo-game-postgres-service | PostgreSQL service name |
| DB_NAME | xo_game | Database name |
| DB_USER | postgres | Database user |
| DB_PASSWORD | postgres | Database password |
| DB_PORT | 5432 | Database port |
| NODE_ENV | production | Node.js environment |

## 🎯 Health Checks

- **Liveness Probe**: `/health` endpoint every 30s
- **Readiness Probe**: `/health` endpoint every 5s
- **Database Health**: `pg_isready` command

## 📊 Resource Limits

- **App**: 128Mi-256Mi RAM, 100m-200m CPU
- **Database**: 256Mi-512Mi RAM, 100m-200m CPU
- **Storage**: 10Gi PostgreSQL data

