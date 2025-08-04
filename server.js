const express = require('express');
const path = require('path');
const sequelize = require('./config/database');
const Game = require('./models/Game')(sequelize);

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// API Routes

// Get all games
app.get('/api/games', async (req, res) => {
  try {
    const games = await Game.findAll({
      order: [['createdAt', 'DESC']],
      limit: 50
    });
    res.json(games);
  } catch (error) {
    console.error('Error fetching games:', error);
    res.status(500).json({ error: 'Failed to fetch games' });
  }
});

// Save a new game result
app.post('/api/games', async (req, res) => {
  try {
    const { winner, moves, finalBoard, duration } = req.body;
    
    if (!winner || !moves || !finalBoard) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const game = await Game.create({
      winner,
      moves,
      finalBoard,
      duration: duration || 0
    });

    res.status(201).json(game);
  } catch (error) {
    console.error('Error saving game:', error);
    res.status(500).json({ error: 'Failed to save game' });
  }
});

// Get game statistics
app.get('/api/stats', async (req, res) => {
  try {
    const totalGames = await Game.count();
    const xWins = await Game.count({ where: { winner: 'X' } });
    const oWins = await Game.count({ where: { winner: 'O' } });
    const draws = await Game.count({ where: { winner: 'draw' } });

    res.json({
      totalGames,
      xWins,
      oWins,
      draws,
      xWinRate: totalGames > 0 ? Math.round((xWins / totalGames) * 100) : 0,
      oWinRate: totalGames > 0 ? Math.round((oWins / totalGames) * 100) : 0,
      drawRate: totalGames > 0 ? Math.round((draws / totalGames) * 100) : 0
    });
  } catch (error) {
    console.error('Error fetching stats:', error);
    res.status(500).json({ error: 'Failed to fetch statistics' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Database initialization
async function initializeDatabase() {
  try {
    await sequelize.authenticate();
    console.log('Database connection established successfully.');
    
    await sequelize.sync({ alter: true });
    console.log('Database synchronized successfully.');
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  }
}

const PORT = process.env.PORT || 8080;

// Initialize database and start server
initializeDatabase().then(() => {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Database: ${process.env.DB_NAME || 'xo_game'}`);
    console.log(`Health check: http://localhost:${PORT}/health`);
  });
});

module.exports = { app, sequelize, Game }; 