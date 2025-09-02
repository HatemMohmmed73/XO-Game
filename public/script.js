/* global document, window */
// DOM elements
const cells = document.querySelectorAll('.cell');
const status = document.getElementById('status');
const resetBtn = document.getElementById('resetBtn');
const gameOverElement = document.getElementById('gameOver');
const winnerText = document.getElementById('winnerText');
const playAgainBtn = document.getElementById('playAgainBtn');

// Game state
let board = Array(9).fill('');
let currentPlayer = 'X';
let gameOver = false;
let winner = null;
let moves = [];
let gameStartTime = Date.now();

// Initialize the game
function initGame() {
  board = Array(9).fill('');
  currentPlayer = 'X';
  gameOver = false;
  winner = null;
  moves = [];
  gameStartTime = Date.now();
  
  updateBoard();
  updateStatus();
  hideGameOver();
}

// Update the game board display
function updateBoard() {
  cells.forEach((cell, index) => {
    const value = board[index];
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

// Hide game over overlay
function hideGameOver() {
  gameOverElement.style.display = 'none';
  winnerText.textContent = '';
}

// Show game over overlay
function showGameOver() {
  winnerText.textContent = status.textContent;
  gameOverElement.style.display = 'flex';
}

// Check for winner
function checkWinner() {
  const winConditions = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6] // diagonals
  ];

  return winConditions.some(condition => {
    const [a, b, c] = condition;
    return board[a] && board[a] === board[b] && board[a] === board[c];
  });
}

// Handle cell clicks
function handleCellClick(event) {
  const cell = event.target;
  const index = parseInt(cell.dataset.index);

  if (gameOver || board[index] !== '') {
    return;
  }

  // Make the move
  board[index] = currentPlayer;
  moves.push({
    player: currentPlayer,
    position: index,
    timestamp: Date.now()
  });
  
  // Check for winner
  if (checkWinner()) {
    gameOver = true;
    winner = currentPlayer;
    showGameOver();
    saveGameResult(winner, moves, board, Date.now() - gameStartTime);
    loadGameStats();
  } else if (board.every(cell => cell !== '')) {
    gameOver = true;
    winner = 'draw';
    showGameOver();
    saveGameResult(winner, moves, board, Date.now() - gameStartTime);
    loadGameStats();
  } else {
    currentPlayer = currentPlayer === 'X' ? 'O' : 'X';
  }

  updateBoard();
  updateStatus();
}

// Reset game
function resetGame() {
  initGame();
  moves = [];
}

// Event listeners
cells.forEach(cell => {
  cell.addEventListener('click', handleCellClick);
});

resetBtn.addEventListener('click', resetGame);

playAgainBtn.addEventListener('click', () => {
  hideGameOver();
  resetGame();
});

// Save game result to database
async function saveGameResult(winner, moves, finalBoard, duration) {
  try {
    const response = await fetch('/api/games', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        winner,
        moves,
        finalBoard,
        duration
      })
    });

    if (!response.ok) {
      throw new Error('Failed to save game result');
    }

    const savedGame = await response.json();
    console.log('Game saved:', savedGame);
    return savedGame;
  } catch (error) {
    console.error('Error saving game:', error);
  }
}

// (Removed old loadGameStats; see enhanced version below)

// Initialize game on load
initGame();

// (Initial call moved to after enhanced definition)

// Display game results
function displayGameResults(stats) {
    if (!stats) return;

    document.getElementById('totalGames').textContent = stats.totalGames || 0;
    document.getElementById('xWins').textContent = stats.xWins || 0;
    document.getElementById('oWins').textContent = stats.oWins || 0;
    document.getElementById('draws').textContent = stats.draws || 0;
}

// Display recent games
function displayRecentGames(games) {
    const gamesList = document.getElementById('gamesList');
    if (!gamesList || !games) return;

    gamesList.innerHTML = '';
    
    if (games.length === 0) {
        gamesList.innerHTML = '<p>No games played yet</p>';
        return;
    }

    games.slice(0, 5).forEach(game => {
        const gameItem = document.createElement('div');
        gameItem.className = `game-item winner-${game.winner}`;
        
        const date = new Date(game.createdAt).toLocaleDateString();
        const winnerText = game.winner === 'draw' ? 'Draw' : `${game.winner} Wins`;
        
        gameItem.innerHTML = `
            <span>${date} - ${winnerText}</span>
            <span>${game.moves.length} moves</span>
        `;
        
        gamesList.appendChild(gameItem);
    });
}

// Enhanced loadGameStats to display results
async function loadGameStats() {
    try {
        const [statsResponse, gamesResponse] = await Promise.all([
            fetch('/api/stats'),
            fetch('/api/games')
        ]);

        const stats = await statsResponse.json();
        const games = await gamesResponse.json();

        displayGameResults(stats);
        displayRecentGames(games);

    } catch (error) {
        console.error('Error loading game data:', error);
    }
}

// Check for game ID in URL parameters (reserved for future use)
const urlParams = new URLSearchParams(window.location.search);
const urlGameId = urlParams.get('game');
// No-op for now

// Ensure stats are loaded on page load (after definition)
loadGameStats();