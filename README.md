# XO Game - Tic Tac Toe with PostgreSQL

A single-player Tic-Tac-Toe game built with Node.js and PostgreSQL, featuring game result persistence and comprehensive statistics tracking.

## Features

- ✅ Single-player Tic-Tac-Toe game
- ✅ PostgreSQL database integration
- ✅ Game result persistence
- ✅ Comprehensive statistics tracking
- ✅ Docker containerization
- ✅ RESTful API endpoints
- ✅ Responsive web design

## Tech Stack

- **Backend**: Node.js, Express.js
- **Database**: PostgreSQL with Sequelize ORM
- **Frontend**: Vanilla JavaScript, CSS3, HTML5
- **Containerization**: Docker & Docker Compose
- **Testing**: Jest with Supertest

## Quick Start

### Option 1: Docker (Recommended)

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd xo-game
   ```

2. **Start with Docker Compose**:
   ```bash
   docker-compose up --build
   ```

3. **Access the application**:
   - Game: http://localhost:4000

### Option 2: Local Development

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Set up PostgreSQL**:
   ```bash
   # Install PostgreSQL
   # Create database: xo_game
   # Create user: postgres with password postgres
   ```

3. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

4. **Start the application**:
   ```bash
   npm start
   ```

## API Endpoints

### Games
- `GET /api/games` - Get all game results
- `POST /api/games` - Save a new game result
- `GET /api/stats` - Get game statistics

### Health
- `GET /health` - Health check endpoint

### Static Files
- `GET /` - Main game interface
- `GET /*` - Static assets

## Database Schema

### Games Table
```sql
CREATE TABLE games (
  id SERIAL PRIMARY KEY,
  winner VARCHAR(10) NOT NULL CHECK (winner IN ('X', 'O', 'draw')),
  moves JSON NOT NULL,
  final_board JSON NOT NULL,
  duration INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 8080 |
| `DB_HOST` | Database host | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_NAME` | Database name | xo_game |
| `DB_USER` | Database user | postgres |
| `DB_PASSWORD` | Database password | postgres |

## Docker Commands

### Development
```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up --build
```

### Production
```bash
# Build production image
docker build -t xo-game .

# Run with environment variables
docker run -p 8080:8080 \
  -e DB_HOST=your-db-host \
  -e DB_PASSWORD=your-password \
  xo-game
```

## Development

### Running Tests
```bash
npm test
```

### Database Reset
```bash
# Reset database (development)
npm run db:reset
```

## File Structure

```
xo-game/
├── config/
│   └── database.js          # Database configuration
├── models/
│   └── Game.js             # Game model (Sequelize)
├── public/
│   ├── index.html          # Main game interface
│   ├── script.js          # Frontend JavaScript
│   └── style.css          # Game styling
├── .env.example           # Environment variables template
├── docker-compose.yml     # Docker services configuration
├── Dockerfile            # App container configuration
├── server.js             # Express server
└── package.json          # Dependencies and scripts
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## License

MIT License - see LICENSE file for details

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
