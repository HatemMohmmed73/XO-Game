# Contributing to XO Game

Thank you for your interest in contributing to XO Game! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites

- **Node.js** 18+ 
- **Docker** 20.10+
- **kubectl** configured
- **Git** for version control

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/yourusername/xo-game.git
   cd xo-game
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Run tests**
   ```bash
   npm test
   npm run lint
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

## 🔄 Development Workflow

### Branch Strategy

- **`main`**: Production-ready code
- **`develop`**: Integration branch for features
- **`feature/*`**: Feature development branches
- **`hotfix/*`**: Critical bug fixes

### Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat: add new load testing scenario
fix: resolve database connection issue
docs: update deployment documentation
test: add unit tests for game logic
refactor: improve error handling
```

### Types

- **feat**: New features
- **fix**: Bug fixes
- **docs**: Documentation changes
- **style**: Code style changes
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

## 🧪 Testing

### Running Tests

```bash
# Unit tests
npm test

# Linting
npm run lint

# Load testing
./scripts/advanced-load-test.sh

# Integration tests
./k8s/simple-stress-test.sh
```

### Test Requirements

- **Unit tests**: All new code must have tests
- **Integration tests**: Test with Kubernetes deployment
- **Load tests**: Verify performance under load
- **Security tests**: Run vulnerability scans

## 📝 Pull Request Process

### Before Submitting

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write tests for new functionality
   - Update documentation if needed
   - Ensure all tests pass

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

4. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

### Pull Request Guidelines

- **Clear title**: Describe what the PR does
- **Detailed description**: Explain changes and motivation
- **Link issues**: Reference related issues
- **Screenshots**: For UI changes
- **Testing**: Describe how you tested

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Load tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🏗️ Architecture Guidelines

### Code Organization

- **`/server.js`**: Main application entry point
- **`/game/`**: Game logic and rules
- **`/models/`**: Database models
- **`/public/`**: Frontend assets
- **`/k8s/`**: Kubernetes manifests
- **`/terraform/`**: Infrastructure as Code
- **`/monitoring/`**: Monitoring configuration

### Kubernetes Best Practices

- **Resource limits**: Always set CPU and memory limits
- **Health checks**: Implement liveness and readiness probes
- **Security**: Use non-root containers
- **Scaling**: Configure HPA for auto-scaling

### Database Guidelines

- **Migrations**: Use proper database migrations
- **Indexing**: Optimize database queries
- **Backup**: Implement backup strategies
- **Monitoring**: Monitor database performance

## 🔒 Security Guidelines

### Security Checklist

- [ ] No hardcoded secrets
- [ ] Use Kubernetes secrets
- [ ] Implement proper authentication
- [ ] Regular security scans
- [ ] Update dependencies regularly

### Vulnerability Reporting

If you discover a security vulnerability, please:

1. **Do not** open a public issue
2. Email security@yourdomain.com
3. Include detailed reproduction steps
4. Allow time for response before disclosure

## 📊 Performance Guidelines

### Performance Targets

- **Response Time**: < 100ms (95th percentile)
- **Throughput**: > 1000 requests/second
- **Availability**: > 99.9% uptime
- **Error Rate**: < 0.1%

### Performance Testing

- **Load testing**: Test with realistic traffic
- **Stress testing**: Find breaking points
- **Endurance testing**: Long-running tests
- **Spike testing**: Sudden traffic increases

## 📚 Documentation

### Documentation Requirements

- **README**: Keep main README updated
- **API docs**: Document all endpoints
- **Deployment**: Document deployment process
- **Troubleshooting**: Common issues and solutions

### Documentation Style

- **Clear and concise**: Easy to understand
- **Examples**: Provide code examples
- **Screenshots**: For UI documentation
- **Links**: Link to related resources

## 🐛 Bug Reports

### Bug Report Template

```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: [e.g., Ubuntu 20.04]
- Node.js: [e.g., 18.17.0]
- Kubernetes: [e.g., 1.28]
- Browser: [e.g., Chrome 91]

## Additional Context
Any other relevant information
```

## 💡 Feature Requests

### Feature Request Template

```markdown
## Feature Description
Clear description of the feature

## Motivation
Why is this feature needed?

## Proposed Solution
How should it work?

## Alternatives
Other solutions considered

## Additional Context
Any other relevant information
```

## 🏷️ Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] Version bumped
- [ ] Changelog updated
- [ ] Security scan passed
- [ ] Performance tests passed

## 🤝 Community Guidelines

### Code of Conduct

- **Be respectful**: Treat everyone with respect
- **Be inclusive**: Welcome contributors of all backgrounds
- **Be constructive**: Provide helpful feedback
- **Be patient**: Remember that everyone is learning

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and ideas
- **Discord**: For real-time chat (if available)
- **Email**: For private matters

## 📞 Contact

- **Maintainer**: [Your Name](mailto:your.email@example.com)
- **Issues**: [GitHub Issues](https://github.com/yourusername/xo-game/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/xo-game/discussions)

---

Thank you for contributing to XO Game! 🎮
