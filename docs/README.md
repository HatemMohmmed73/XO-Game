# XO Game - Complete Infrastructure Documentation

## 🎯 Overview

This is a comprehensive, production-ready setup for the XO Game application with:

- **Kubernetes orchestration** with auto-scaling
- **Distributed PostgreSQL cluster** for high availability
- **Shared storage** across all nodes
- **Complete monitoring** with Prometheus and Grafana
- **CI/CD pipeline** with GitHub Actions
- **Advanced load testing** suite
- **Infrastructure as Code** with Terraform

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

### 1. Deploy with Scripts

```bash
# Fast deployment (recommended)
./k8s/fast-deploy.sh

# Or use Terraform
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Run Load Tests

```bash
# Simple stress test
./k8s/simple-stress-test.sh

# Advanced load testing
./scripts/advanced-load-test.sh

# Interactive load testing
./k8s/load-test.sh
```

### 3. Monitor System

```bash
# Check status
kubectl get pods -n xo-game
kubectl get hpa -n xo-game

# View logs
kubectl logs -l app=xo-game,test=stress -n xo-game
```

## 📁 Project Structure

```
XO-Game/
├── k8s/                          # Kubernetes manifests
│   ├── fast-deploy.sh           # Quick deployment script
│   ├── load-test.sh             # Interactive load testing
│   ├── simple-stress-test.sh    # Simple stress test
│   ├── stress-test-deployment.yaml
│   ├── postgres-cluster-deployment.yaml
│   ├── hpa.yaml                 # Auto-scaling configuration
│   └── shared-storage.yaml      # Shared storage setup
├── terraform/                   # Infrastructure as Code
│   ├── main.tf                  # Main Terraform configuration
│   ├── variables.tf             # Terraform variables
│   └── outputs.tf               # Terraform outputs
├── monitoring/                  # Monitoring setup
│   ├── prometheus-config.yaml   # Prometheus configuration
│   └── grafana-dashboard.json   # Grafana dashboard
├── scripts/                     # Utility scripts
│   └── advanced-load-test.sh    # Comprehensive load testing
├── .github/workflows/           # CI/CD pipeline
│   └── deploy.yml               # GitHub Actions workflow
└── docs/                        # Documentation
    └── README.md                # This file
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

### Scaling Configuration

The system automatically scales based on:

- **CPU usage** > 60%
- **Memory usage** > 70%
- **Custom metrics** (if configured)

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

### Alerts

- **High CPU/Memory usage**
- **Pod failures**
- **Database connection issues**
- **High request latency**

## 🧪 Load Testing

### Test Scenarios

1. **Light Load**: 10 users, 1 minute
2. **Medium Load**: 50 users, 5 minutes
3. **Heavy Load**: 100 users, 10 minutes
4. **Extreme Load**: 200 users, 15 minutes

### Load Testing Tools

- **hey**: Professional load testing tool
- **curl**: Simple HTTP testing
- **Custom scripts**: Advanced scenarios

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

1. **Build & Test**: Node.js tests, linting
2. **Security Scan**: Vulnerability scanning
3. **Deploy Staging**: Automated staging deployment
4. **Deploy Production**: Production deployment
5. **Performance Test**: Automated load testing
6. **Notify**: Slack notifications

### Deployment Environments

- **Staging**: `develop` branch
- **Production**: `main` branch

## 🛠️ Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod status
kubectl get pods -n xo-game

# Check pod logs
kubectl describe pod <pod-name> -n xo-game
kubectl logs <pod-name> -n xo-game
```

#### Database Connection Issues
```bash
# Check database pods
kubectl get pods -n xo-game -l component=postgres-cluster

# Check database logs
kubectl logs -l component=postgres-cluster -n xo-game
```

#### Auto-scaling Not Working
```bash
# Check HPA status
kubectl get hpa -n xo-game

# Check HPA events
kubectl describe hpa xo-game-hpa -n xo-game
```

#### Storage Issues
```bash
# Check PVC status
kubectl get pvc -n xo-game

# Check PV status
kubectl get pv
```

### Performance Optimization

1. **Resource Limits**: Adjust CPU/memory limits
2. **Replica Count**: Optimize initial replica count
3. **HPA Thresholds**: Fine-tune scaling thresholds
4. **Database Tuning**: Optimize PostgreSQL configuration

## 🔒 Security

### Best Practices

- **Non-root containers**: All containers run as non-root
- **Resource limits**: CPU and memory limits set
- **Network policies**: Restrict network access
- **Secrets management**: Use Kubernetes secrets
- **Image scanning**: Regular vulnerability scanning

### Security Scanning

- **Trivy**: Container vulnerability scanning
- **CodeQL**: Code security analysis
- **Dependabot**: Dependency updates

## 📈 Performance Metrics

### Key Performance Indicators

- **Response Time**: < 100ms (95th percentile)
- **Throughput**: > 1000 requests/second
- **Availability**: > 99.9% uptime
- **Error Rate**: < 0.1%

### Monitoring Queries

```promql
# Request rate
rate(http_requests_total[5m])

# Response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])
```

## 🤝 Contributing

1. **Fork the repository**
2. **Create a feature branch**
3. **Make your changes**
4. **Run tests and linting**
5. **Submit a pull request**

### Development Setup

```bash
# Install dependencies
npm install

# Run tests
npm test

# Run linting
npm run lint

# Build Docker image
docker build -t xo-game:latest .
```

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: This README
- **Monitoring**: Grafana dashboards
- **Logs**: Kubernetes logs

## 📄 License

MIT License - see LICENSE file for details.

---

**Built with ❤️ for high-performance, scalable applications**
