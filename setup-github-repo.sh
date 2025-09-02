#!/bin/bash

# GitHub Repository Setup Script for XO Game
echo "🚀 Setting up GitHub Repository for XO Game"
echo "============================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}📦 Initializing Git repository...${NC}"
    git init
    echo -e "${GREEN}✅ Git repository initialized${NC}"
else
    echo -e "${GREEN}✅ Git repository already exists${NC}"
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}📦 Installing GitHub CLI...${NC}"
    
    # Install GitHub CLI
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install gh
else
    echo -e "${GREEN}✅ GitHub CLI is already installed${NC}"
fi

# Authenticate with GitHub
echo -e "${YELLOW}🔐 Authenticating with GitHub...${NC}"
gh auth login

# Get repository name
read -p "Enter your GitHub username: " GITHUB_USERNAME
read -p "Enter repository name (default: xo-game): " REPO_NAME
REPO_NAME=${REPO_NAME:-xo-game}

# Create repository on GitHub
echo -e "${YELLOW}📦 Creating repository on GitHub...${NC}"
gh repo create $REPO_NAME --public --description "🎮 XO Game - Production-Ready Kubernetes Application with Auto-scaling, Monitoring, and CI/CD" --add-readme=false

# Add remote origin
echo -e "${YELLOW}🔗 Adding remote origin...${NC}"
git remote add origin https://github.com/$GITHUB_USERNAME/$REPO_NAME.git

# Add all files
echo -e "${YELLOW}📁 Adding files to Git...${NC}"
git add .

# Create initial commit
echo -e "${YELLOW}💾 Creating initial commit...${NC}"
git commit -m "feat: initial commit - complete XO Game infrastructure

- 🎮 XO Game application with Node.js
- ☸️ Kubernetes deployment with auto-scaling
- 🗄️ Distributed PostgreSQL cluster
- 💾 Shared storage across all nodes
- 📊 Complete monitoring with Prometheus & Grafana
- 🔄 CI/CD pipeline with GitHub Actions
- 🧪 Advanced load testing suite
- 🏗️ Infrastructure as Code with Terraform
- 📚 Comprehensive documentation"

# Push to GitHub
echo -e "${YELLOW}📤 Pushing to GitHub...${NC}"
git branch -M main
git push -u origin main

# Set up branch protection rules
echo -e "${YELLOW}🛡️ Setting up branch protection rules...${NC}"
gh api repos/$GITHUB_USERNAME/$REPO_NAME/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["CI"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null

# Enable GitHub Actions
echo -e "${YELLOW}🔄 Enabling GitHub Actions...${NC}"
gh api repos/$GITHUB_USERNAME/$REPO_NAME/actions/permissions \
  --method PUT \
  --field enabled=true \
  --field allowed_actions=all

# Create issues for initial tasks
echo -e "${YELLOW}📋 Creating initial issues...${NC}"

# Issue 1: Setup monitoring
gh issue create \
  --title "📊 Setup Prometheus and Grafana monitoring" \
  --body "## Description
Set up comprehensive monitoring for the XO Game application.

## Tasks
- [ ] Deploy Prometheus
- [ ] Deploy Grafana
- [ ] Configure custom dashboards
- [ ] Set up alerting rules
- [ ] Test monitoring endpoints

## Acceptance Criteria
- [ ] Prometheus is collecting metrics
- [ ] Grafana dashboards are working
- [ ] Alerts are configured
- [ ] Documentation is updated

## Priority
High

## Labels
enhancement, monitoring" \
  --label "enhancement,monitoring"

# Issue 2: Performance optimization
gh issue create \
  --title "⚡ Performance optimization and tuning" \
  --body "## Description
Optimize the XO Game application for better performance.

## Tasks
- [ ] Analyze current performance metrics
- [ ] Optimize database queries
- [ ] Tune Kubernetes resource limits
- [ ] Implement caching strategies
- [ ] Run comprehensive load tests

## Acceptance Criteria
- [ ] Response time < 100ms (95th percentile)
- [ ] Throughput > 1000 requests/second
- [ ] Error rate < 0.1%
- [ ] Resource utilization optimized

## Priority
Medium

## Labels
enhancement, performance" \
  --label "enhancement,performance"

# Issue 3: Security hardening
gh issue create \
  --title "🔒 Security hardening and compliance" \
  --body "## Description
Implement additional security measures and compliance checks.

## Tasks
- [ ] Implement network policies
- [ ] Add security scanning to CI/CD
- [ ] Set up secrets management
- [ ] Implement RBAC
- [ ] Add security headers

## Acceptance Criteria
- [ ] Network policies are enforced
- [ ] Security scans pass
- [ ] Secrets are properly managed
- [ ] RBAC is configured
- [ ] Security documentation is updated

## Priority
High

## Labels
security, compliance" \
  --label "security,compliance"

# Create project board
echo -e "${YELLOW}📋 Creating project board...${NC}"
gh project create \
  --title "XO Game Development" \
  --body "Project board for XO Game development tasks" \
  --public

# Add repository to project
PROJECT_ID=$(gh project list --owner $GITHUB_USERNAME --json id,title --jq '.[] | select(.title == "XO Game Development") | .id')
gh project item-add $PROJECT_ID --owner $GITHUB_USERNAME --repo $REPO_NAME

echo ""
echo -e "${GREEN}🎉 GitHub repository setup completed!${NC}"
echo ""
echo -e "${BLUE}📋 Repository Information:${NC}"
echo "   • Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "   • Issues: https://github.com/$GITHUB_USERNAME/$REPO_NAME/issues"
echo "   • Actions: https://github.com/$GITHUB_USERNAME/$REPO_NAME/actions"
echo "   • Project: https://github.com/$GITHUB_USERNAME/$REPO_NAME/projects"
echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "   1. Update the README.md with your actual GitHub username"
echo "   2. Configure GitHub Actions secrets (KUBE_CONFIG, SLACK_WEBHOOK)"
echo "   3. Set up monitoring and alerting"
echo "   4. Run your first load test"
echo "   5. Start developing new features!"
echo ""
echo -e "${GREEN}🚀 Your XO Game repository is ready for development!${NC}"
