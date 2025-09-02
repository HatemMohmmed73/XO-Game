# 🎮 XO Game - Production-Ready Kubernetes Application

[![CI/CD](https://github.com/yourusername/xo-game/workflows/Deploy%20XO%20Game%20to%20Kubernetes/badge.svg)](https://github.com/yourusername/xo-game/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-blue.svg)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)

A high-performance, scalable XO (Tic-Tac-Toe) game built with Node.js, deployed on Kubernetes with complete infrastructure automation, monitoring, and CI/CD pipeline.

## 🚀 Features

- **🎯 High Performance**: Auto-scaling Kubernetes deployment (4-16 replicas)
- **🗄️ High Availability**: Distributed PostgreSQL cluster with 3 nodes
- **💾 Data Persistence**: Shared storage across all nodes
- **📊 Complete Monitoring**: Prometheus + Grafana with custom dashboards
- **🔄 CI/CD Pipeline**: Automated testing, security scanning, and deployment
- **🧪 Advanced Load Testing**: Comprehensive testing suite with multiple scenarios
- **🏗️ Infrastructure as Code**: Complete Terraform configuration
- **🔒 Security**: Vulnerability scanning, non-root containers, resource limits

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    XO Game Infrastructure                    │
├─────────────────────────────────────────────────────────────┤
│  Load Balancer (HPA)                                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ App Pod 1   │ │ App Pod 2   │ │ App Pod N   │           │
│  │ (Shared     │ │ (Shared     │ │ (Shared     │           │
│  │  Storage)   │ │  Storage)   │ │  Storage)   │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
├─────────────────────────────────────────────────────────────┤
│  Database Cluster (PostgreSQL)                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ DB Node 1   │ │ DB Node 2   │ │ DB Node 3   │           │
│  │ (Primary)   │ │ (Replica)   │ │ (Replica)   │           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
├─────────────────────────────────────────────────────────────┤
│  Monitoring & Observability                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │
│  │ Prometheus  │ │ Grafana     │ │ AlertManager│           │
│  └─────────────┘ └─────────────┘ └─────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Kubernetes cluster** (minikube, kind, k3d, or cloud)
- **kubectl** configured
- **Docker** for building images
- **Terraform** (optional, for IaC)

### 1. Clone and Deploy

```bash
<<<<<<< HEAD
# Clone the repository
git clone https://github.com/yourusername/xo-game.git
cd xo-game

# Deploy everything with one command
./deploy-all.sh

# Or use Terraform
./deploy-all.sh terraform
=======
docker-compose up -d
>>>>>>> 891f9323808c0a11bcd845df51611248657de4ba
```

### 2. Access Your Application

```bash
# Get the service IP
kubectl get service xo-game-stress-test-service -n xo-game

# Access the game
curl http://<SERVICE_IP>:8080
```

### 3. Run Load Tests

```bash
# Simple stress test
./k8s/simple-stress-test.sh

# Advanced load testing
./scripts/advanced-load-test.sh

# Interactive load testing
./k8s/load-test.sh
```

## 📁 Project Structure

```
XO-Game/
├── 🎮 Application
│   ├── server.js              # Main application server
│   ├── game/XOGame.js         # Game logic
│   ├── models/Game.js         # Database models
│   └── public/                # Frontend assets
├── ☸️  Kubernetes
│   ├── k8s/                   # Kubernetes manifests
│   │   ├── fast-deploy.sh     # Quick deployment
│   │   ├── load-test.sh       # Load testing
│   │   └── *.yaml             # Resource definitions
├── 🏗️  Infrastructure
│   ├── terraform/             # Infrastructure as Code
│   │   ├── main.tf            # Main configuration
│   │   ├── variables.tf       # Variables
│   │   └── outputs.tf         # Outputs
├── 📊 Monitoring
│   ├── monitoring/            # Monitoring setup
│   │   ├── prometheus-config.yaml
│   │   └── grafana-dashboard.json
├── 🔄 CI/CD
│   ├── .github/workflows/     # GitHub Actions
│   │   └── deploy.yml         # Deployment pipeline
├── 🧪 Testing
│   ├── scripts/               # Test scripts
│   │   └── advanced-load-test.sh
│   └── tests/                 # Unit tests
└── 📚 Documentation
    └── docs/                  # Documentation
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NAMESPACE` | `xo-game` | Kubernetes namespace |
| `APP_REPLICAS` | `8` | Number of app replicas |
| `POSTGRES_REPLICAS` | `3` | Number of database replicas |
| `MIN_REPLICAS` | `4` | Minimum replicas for HPA |
| `MAX_REPLICAS` | `16` | Maximum replicas for HPA |
| `CPU_TARGET` | `60%` | CPU target for auto-scaling |
| `MEMORY_TARGET` | `70%` | Memory target for auto-scaling |

## 📊 Monitoring

### Prometheus Metrics

- **Application metrics**: Request rate, latency, errors
- **Kubernetes metrics**: Pod status, resource usage
- **Database metrics**: Connection count, query performance

### Grafana Dashboards

- **System Overview**: Pod status, resource usage
- **Application Performance**: Request rate, response time
- **Database Health**: Connection status, query metrics
- **Auto-scaling**: HPA status, scaling events

## 🧪 Load Testing

### Test Scenarios

1. **Light Load**: 10 users, 1 minute
2. **Medium Load**: 50 users, 5 minutes
3. **Heavy Load**: 100 users, 10 minutes
4. **Extreme Load**: 200 users, 15 minutes

### Performance Targets

- **Response Time**: < 100ms (95th percentile)
- **Throughput**: > 1000 requests/second
- **Availability**: > 99.9% uptime
- **Error Rate**: < 0.1%

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

1. **Build & Test**: Node.js tests, linting
2. **Security Scan**: Vulnerability scanning
3. **Deploy Staging**: Automated staging deployment
4. **Deploy Production**: Production deployment
5. **Performance Test**: Automated load testing
6. **Notify**: Slack notifications

## 🛠️ Development

### Local Development

```bash
# Install dependencies
npm install

# Run tests
npm test

# Run linting
npm run lint

# Start development server
npm run dev

# Build Docker image
docker build -t xo-game:latest .
```

### Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Run tests and linting**
5. **Submit a pull request**

## 🔒 Security

### Security Features

- **Non-root containers**: All containers run as non-root
- **Resource limits**: CPU and memory limits set
- **Network policies**: Restrict network access
- **Secrets management**: Use Kubernetes secrets
- **Image scanning**: Regular vulnerability scanning

## 📈 Performance

### Key Performance Indicators

- **Response Time**: < 100ms (95th percentile)
- **Throughput**: > 1000 requests/second
- **Availability**: > 99.9% uptime
- **Error Rate**: < 0.1%

## 🛠️ Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
kubectl get pods -n xo-game
kubectl describe pod <pod-name> -n xo-game
kubectl logs <pod-name> -n xo-game
```

#### Database Connection Issues
```bash
kubectl get pods -n xo-game -l component=postgres-cluster
kubectl logs -l component=postgres-cluster -n xo-game
```

#### Auto-scaling Not Working
```bash
kubectl get hpa -n xo-game
kubectl describe hpa xo-game-hpa -n xo-game
```

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/xo-game/issues)
- **Documentation**: [Full Documentation](docs/README.md)
- **Monitoring**: Grafana dashboards
- **Logs**: Kubernetes logs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Kubernetes** for orchestration
- **Prometheus** for monitoring
- **Grafana** for visualization
- **Terraform** for infrastructure as code
- **GitHub Actions** for CI/CD

---

<<<<<<< HEAD
**Built with ❤️ for high-performance, scalable applications**
=======
## 🧪 Local Development & Testing

* Start services:

  ```bash
  docker-compose up -d
  ```

* Stop services:

  ```bash
  docker-compose down
  ```

* Rebuild images:

  ```bash
  docker-compose up --build
  ```

---

## 🔧 Troubleshooting Guide

| Issue                   | Solution                                                               |
| ----------------------- | ---------------------------------------------------------------------- |
| DB connection fails     | Check your `DB_HOST` and environment variables in `docker-compose.yml` |
| Port conflicts          | Change ports in `docker-compose.yml` to avoid conflicts                |
| Docker image push fails | Ensure GitHub token (`GITHUB_TOKEN`) has `packages: write` permissions |
| Health check fails      | Make sure your app exposes `/health` endpoint as configured            |

---

## 🎯 Deployment Checklist

* ✅ Added `docker-compose.yml`
* ✅ Created `Dockerfile`
* ✅ Added GitHub Actions workflow `.github/workflows/ci-cd.yml`
* ✅ Configured environment variables correctly
* ✅ GitHub Actions workflows run successfully
* ✅ Your app responds correctly on `http://localhost:4000/health`

---

# Enjoy your automated Docker Compose CI/CD setup! 🎉

Feel free to open issues or PRs on [XO-Game repo](https://github.com/HatemMohmmed73/XO-Game) for improvements.
>>>>>>> 891f9323808c0a11bcd845df51611248657de4ba

⭐ **Star this repository if you find it helpful!**