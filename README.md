# Al-Mallah - Oman Tourism & Cultural Platform

A comprehensive tourism and cultural platform for Oman, showcasing the country's rich heritage, attractions, and culinary experiences.

## Features

- 🏞️ Discover tourist attractions and places
- 🍽️ Explore restaurants and cafes
- 🥾 Find hiking trails
- 👨‍🍳 Traditional Omani recipes
- ✨ User-generated content submission
- 🏆 Profile system with gamification

## Tech Stack

- Frontend: React 19.1.0
- Styling: Tailwind CSS 4.1.11
- Progressive Web App (PWA) enabled
- Responsive design for all devices

## Design System

- Primary Color: Mountain Green (#3B6B4E)
- Typography: "The Year of Handicrafts" font for headings
- Component-based architecture
- Modern, accessible UI components

---

## CI/CD Pipeline Setup Guide

This guide explains how to set up a complete CI/CD pipeline for a Node.js project using GitHub Actions and Render. It covers the three main stages (Build, Test, Deploy), how to configure deployment to Render using a deploy hook, and how to verify your deployment.

---

## 1. Pipeline Overview

The pipeline consists of **three stages**:

1. **Build Stage**: Installs dependencies and prepares the application for deployment.
2. **Test Stage**: Runs automated tests and health checks to ensure code quality.
3. **Deploy Stage**: Triggers a deployment to Render using a secure deploy hook.

---

## 2. Prerequisites

- A GitHub repository for your Node.js project
- A [Render](https://render.com/) account
- Your app set up as a Render Web Service (Node.js)

---

## 3. Step-by-Step CI/CD Setup

### Step 1: Create a Render Web Service
1. Log in to [Render](https://render.com/)
2. Click **New +** → **Web Service**
3. Connect your GitHub repo and select your project
4. Set the build command: `npm install`
5. Set the start command: `npm start`
6. Complete the setup and deploy your service

### Step 2: Get Render Deploy Hook
1. In your Render service dashboard, go to **Settings**
2. Scroll to **Deploy Hooks**
3. Copy ** Deploy Hook**

### Step 3: Add the Deploy Hook to GitHub Secrets
1. Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `RENDER_DEPLOY_HOOK`
4. Value: (Paste your Render deploy hook URL)
5. Click **Add secret**

### Step 4: Add the CI/CD Workflow File
1. In your repo, create `.github/workflows/three-stage.yml` with the following structure:

```yaml
name: 3-Stage CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    name: Build Stage
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Build application
        run: |
          mkdir -p dist
          cp -r public dist/
          cp server.js dist/
          cp package.json dist/
          cp package-lock.json dist/
          cd dist && npm ci --only=production
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: dist/
          retention-days: 7

  test:
    name: Test Stage
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run linting (optional)
        run: npm run lint || echo "Linting failed but continuing..."
        continue-on-error: true
      - name: Run unit tests
        run: npm test -- --verbose --detectOpenHandles
      - name: Test server health (with retry)
        run: |
          npm start &
          SERVER_PID=$!
          for i in {1..30}; do
            if curl -f http://localhost:3000/health > /dev/null 2>&1; then
              echo "Server is ready!"
              break
            fi
            sleep 2
          done
          curl -f http://localhost:3000/health
          kill $SERVER_PID || true
          wait $SERVER_PID 2>/dev/null || true
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
          path: dist/
      - name: Test built application
        run: |
          cd dist
          npm start &
          SERVER_PID=$!
          for i in {1..30}; do
            if curl -f http://localhost:3000/health > /dev/null 2>&1; then
              echo "Built server is ready!"
              break
            fi
            sleep 2
          done
          curl -f http://localhost:3000/health
          kill $SERVER_PID || true
          wait $SERVER_PID 2>/dev/null || true

  deploy:
    name: Deploy to Render
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Trigger Render Deploy Hook
        run: |
          curl -X POST "$RENDER_DEPLOY_HOOK"
        env:
          RENDER_DEPLOY_HOOK: ${{ secrets.RENDER_DEPLOY_HOOK }}
      - name: Notify deployment success
        run: |
          echo "🚀 Successfully triggered Render deployment!"
          echo "Application is live at: https://your-app.onrender.com/"
```

---

## 4. How to Check Deployment Status

### A. On GitHub Actions
- Go to your repo → **Actions** tab
- Click on the latest workflow run
- Ensure all three stages (Build, Test, Deploy) are green

### B. On Render
- Go to your Render dashboard
- Open your service
- Check the **Events** tab for deployment status
- You should see a new deployment triggered by the deploy hook

### C. Using the Deploy Hook
- The deploy step in your workflow triggers the deploy hook via `curl`
- You can also manually trigger a deployment by running:
  ```bash
  curl -X POST "<your-render-deploy-hook-url>"
  ```
- This will start a new deployment on Render

---

## 5. Troubleshooting

- **Malformed input to a URL function**: Check that your `RENDER_DEPLOY_HOOK` secret is set correctly and contains the full URL.
- **Deployment not triggered**: Make sure the deploy hook is correct and your workflow references the secret properly.
- **Build or test failures**: Check the logs in the Actions tab for details.

---

## 6. Summary

- Set up your Render service and deploy hook
- Add the deploy hook as a GitHub secret
- Use the provided workflow for a 3-stage CI/CD pipeline
- Every push to `main` will build, test, and deploy your app to Render automatically

---

For more details, see [Render Deploy Hooks Documentation](https://render.com/docs/deploy-hooks).
