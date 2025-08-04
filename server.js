const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Game state
const games = new Map();

// Game logic
class XOGame {
  constructor() {
    this.board = Array(9).fill('');
    this.currentPlayer = 'X';
    this.gameOver = false;
    this.winner = null;
    this.players = [];
  }

  makeMove(position) {
    if (this.gameOver || this.board[position] !== '') {
      return false;
    }

    this.board[position] = this.currentPlayer;
    
    if (this.checkWinner()) {
      this.gameOver = true;
      this.winner = this.currentPlayer;
    } else if (this.board.every(cell => cell !== '')) {
      this.gameOver = true;
      this.winner = 'draw';
    } else {
      this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
    }

    return true;
  }

  checkWinner() {
    const winConditions = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6] // diagonals
    ];

    return winConditions.some(condition => {
      const [a, b, c] = condition;
      return this.board[a] && this.board[a] === this.board[b] && this.board[a] === this.board[c];
    });
  }

  reset() {
    this.board = Array(9).fill('');
    this.currentPlayer = 'X';
    this.gameOver = false;
    this.winner = null;
  }
}

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  socket.on('joinGame', (gameId) => {
    let game = games.get(gameId);
    
    if (!game) {
      game = new XOGame();
      games.set(gameId, game);
    }

    if (game.players.length < 2) {
      game.players.push(socket.id);
      socket.join(gameId);
      socket.gameId = gameId;
      
      io.to(gameId).emit('gameState', {
        board: game.board,
        currentPlayer: game.currentPlayer,
        gameOver: game.gameOver,
        winner: game.winner,
        players: game.players.length
      });
    } else {
      socket.emit('gameFull');
    }
  });

  socket.on('makeMove', (position) => {
    const game = games.get(socket.gameId);
    if (game && game.makeMove(position)) {
      io.to(socket.gameId).emit('gameState', {
        board: game.board,
        currentPlayer: game.currentPlayer,
        gameOver: game.gameOver,
        winner: game.winner,
        players: game.players.length
      });
    }
  });

  socket.on('resetGame', () => {
    const game = games.get(socket.gameId);
    if (game) {
      game.reset();
      io.to(socket.gameId).emit('gameState', {
        board: game.board,
        currentPlayer: game.currentPlayer,
        gameOver: game.gameOver,
        winner: game.winner,
        players: game.players.length
      });
    }
  });

  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    if (socket.gameId) {
      const game = games.get(socket.gameId);
      if (game) {
        game.players = game.players.filter(id => id !== socket.id);
        if (game.players.length === 0) {
          games.delete(socket.gameId);
        }
      }
    }
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;

// Only start the server if this is the main module (not being imported for testing)
if (require.main === module) {
  server.listen(PORT, () => {
    console.log(`XO Game server running on port ${PORT}`);
  });
}

module.exports = { app, server, io, XOGame }; 