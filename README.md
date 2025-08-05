


# 🚀 Complete Node.js + PostgreSQL CI/CD Tutorial with Docker Compose

Deploy any Node.js app with PostgreSQL using Docker Compose and GitHub Actions in minutes.

This guide works with **any Node.js app** that uses PostgreSQL.  
You can also use my example repository:  
🔗 [XO-Game Example Repo](https://github.com/HatemMohmmed73/XO-Game)



## 🎯 What You’ll Build

- ✅ Universal setup – works with Express, NestJS, Fastify, etc.  
- ✅ PostgreSQL + Node.js with Docker Compose – run full stack locally in one command  
- ✅ GitHub Actions CI/CD – automated building, testing, and pushing to GitHub Container Registry (GHCR)  
- ✅ Portable containers – run anywhere with Docker  
- ✅ Ready for production – environment variables & health checks included


## 📋 Prerequisites (2 minutes setup)

- A **GitHub repository** (free)  
- **Docker** & **Docker Compose** installed locally  
- (Optional) Use my example repo:  
  ```bash
  git clone https://github.com/HatemMohmmed73/XO-Game.git
  cd XO-Game

## 🏗 Project Structure

```
├── .github/workflows/
│   └── ci-cd.yml          # 🚀 Your CI/CD pipeline
├── docker-compose.yml     # 🐳 Services definition
├── Dockerfile             # 🐳 Node.js container
├── package.json           # 📦 Dependencies & scripts
└── README.md              # 📖 Project info
```
---

## 🚀 Complete Deployment Guide

### Step 1: Create `docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: xo-game-db
    environment:
      POSTGRES_DB: xo_game
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - xo-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Node.js Application
  app:
    build: .
    container_name: xo-game-app
    ports:
      - "4000:8080"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_NAME=xo_game
      - DB_USER=postgres
      - DB_PASSWORD=postgres
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - xo-network
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  xo-network:
    driver: bridge
```

---

### Step 2: Create `Dockerfile`

```dockerfile
# Use official Node.js runtime as base image
FROM node:18-alpine

# Install curl for health check
RUN apk add --no-cache curl

# Set working directory in container
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev for build)
RUN npm ci

# Copy application code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Start the application
CMD ["npm", "start"]
```

---

### Step 3: Create GitHub Actions Workflow `.github/workflows/ci-cd.yml`

```yaml
name: Node.js CI/CD with Docker Compose

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    steps:
    - uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Install Docker Compose
      run: |
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        docker-compose --version

    - name: Log in to GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Build Docker images with Compose
      run: docker-compose build

    - name: Find and push built image
      run: |
        REPO_OWNER=$(echo "${{ github.repository_owner }}" | tr '[:upper:]' '[:lower:]')
        REPO_NAME=$(echo "${{ github.repository }}" | cut -d'/' -f2 | tr '[:upper:]' '[:lower:]')
        IMAGE_ID=$(docker images --format "{{.ID}}" | head -n 1)
        TARGET_IMAGE="ghcr.io/$REPO_OWNER/$REPO_NAME:latest"
        docker tag "$IMAGE_ID" "$TARGET_IMAGE"
        docker push "$TARGET_IMAGE"

  test:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Use Node.js 18.x
      uses: actions/setup-node@v4
      with:
        node-version: 18.x
        cache: 'npm'
    - name: Install dependencies
      run: npm ci
    - name: Run tests
      run: npm test

  deploy:
    needs: [build-and-push, test]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deploy to production
      run: echo "Deployment commands go here"
```

---

### Step 4: Run Locally with Docker Compose

```bash
docker-compose up --build
```

* Your app will be available at: `http://localhost:4000`
* PostgreSQL listens on: `localhost:5432`

---

### Step 5: Push and Trigger CI/CD

```bash
git add .
git commit -m "Add Docker Compose and CI/CD workflow"
git push origin main
```

* GitHub Actions will **build**, **push** the Docker images to GHCR, and run tests automatically.
* Add real deployment commands in the `deploy` job if needed.

---

## 🧪 Local Development & Testing

* Start services:

  ```bash
  docker-compose up
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

