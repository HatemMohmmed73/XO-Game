/* global document, window, navigator, alert, io */
// Connect to Socket.IO server
const socket = io();

// DOM elements
const cells = document.querySelectorAll('.cell');
const status = document.getElementById('status');
const playerCount = document.getElementById('playerCount');
const resetBtn = document.getElementById('resetBtn');
const shareBtn = document.getElementById('shareBtn');
const gameOverElement = document.getElementById('gameOver');
const winnerText = document.getElementById('winnerText');
const playAgainBtn = document.getElementById('playAgainBtn');

// Game state
let gameId = generateGameId();
let currentPlayer = 'X';
let gameOver = false;
let winner = null;

// Generate a random game ID
function generateGameId() {
  return Math.random().toString(36).substring(2, 8);
}

// Update the game board display
function updateBoard(boardState) {
  cells.forEach((cell, index) => {
    const value = boardState[index];
    cell.textContent = value;
    cell.className = 'cell';
    if (value) {
      cell.classList.add(value.toLowerCase());
    }
  });
}

// Update game status
function updateStatus() {
  if (gameOver) {
    if (winner === 'draw') {
      status.textContent = 'It\'s a draw!';
    } else {
      status.textContent = `Player ${winner} wins!`;
    }
  } else {
    status.textContent = `Current player: ${currentPlayer}`;
  }
}

// Show game over overlay
function showGameOver() {
  if (winner === 'draw') {
    winnerText.textContent = 'It\'s a draw!';
  } else {
    winnerText.textContent = `Player ${winner} wins!`;
  }
  gameOverElement.style.display = 'flex';
}

// Hide game over overlay
function hideGameOver() {
  gameOverElement.style.display = 'none';
}

// Handle cell clicks
function handleCellClick(event) {
  if (gameOver) return;
    
  const cell = event.target;
  const index = parseInt(cell.dataset.index);
    
  if (cell.textContent === '') {
    socket.emit('makeMove', index);
  }
}

// Share game functionality
function shareGame() {
  const gameUrl = `${window.location.origin}?game=${gameId}`;
    
  if (navigator.share) {
    navigator.share({
      title: 'XO Game',
      text: 'Join me for a game of XO!',
      url: gameUrl
    });
  } else {
    // Fallback: copy to clipboard
    navigator.clipboard.writeText(gameUrl).then(() => {
      alert('Game link copied to clipboard!');
    }).catch(() => {
      // Fallback for older browsers
      const textArea = document.createElement('textarea');
      textArea.value = gameUrl;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      alert('Game link copied to clipboard!');
    });
  }
}

// Event listeners
cells.forEach(cell => {
  cell.addEventListener('click', handleCellClick);
});

resetBtn.addEventListener('click', () => {
  socket.emit('resetGame');
  hideGameOver();
});

shareBtn.addEventListener('click', shareGame);

playAgainBtn.addEventListener('click', () => {
  socket.emit('resetGame');
  hideGameOver();
});

// Socket.IO event handlers
socket.on('connect', () => {
  console.log('Connected to server');
  socket.emit('joinGame', gameId);
});

socket.on('gameState', (data) => {
  updateBoard(data.board);
  currentPlayer = data.currentPlayer;
  gameOver = data.gameOver;
  winner = data.winner;
    
  updateStatus();
  playerCount.textContent = `Players: ${data.players}/2`;
    
  if (gameOver) {
    showGameOver();
  } else {
    hideGameOver();
  }
});

socket.on('gameFull', () => {
  status.textContent = 'Game is full!';
  alert('This game is full. Please create a new game or join a different one.');
});

socket.on('disconnect', () => {
  status.textContent = 'Disconnected from server';
});

// Check for game ID in URL parameters
const urlParams = new URLSearchParams(window.location.search);
const urlGameId = urlParams.get('game');
if (urlGameId) {
  gameId = urlGameId;
}

// Initialize game
socket.emit('joinGame', gameId); 