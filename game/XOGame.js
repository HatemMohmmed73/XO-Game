class XOGame {
  constructor() {
    this.board = Array(9).fill('');
    this.currentPlayer = 'X';
    this.gameOver = false;
    this.winner = null;
  }

  makeMove(pos) {
    if (this.gameOver || this.board[pos] !== '') return false;
    this.board[pos] = this.currentPlayer;
    
    if (this.checkWin()) {
      this.gameOver = true;
      this.winner = this.currentPlayer;
    } else if (this.checkDraw()) {
      this.gameOver = true;
      this.winner = 'draw';
    } else {
      this.currentPlayer = this.currentPlayer === 'X' ? 'O' : 'X';
    }
    return true;
  }

  checkWin() {
    const wins = [
      [0,1,2], [3,4,5], [6,7,8], // rows
      [0,3,6], [1,4,7], [2,5,8], // columns
      [0,4,8], [2,4,6]  // diagonals
    ];
    return wins.some(([a,b,c]) => 
      this.board[a] && 
      this.board[a] === this.board[b] && 
      this.board[a] === this.board[c]
    );
  }

  checkDraw() { 
    return this.board.every(cell => cell !== '');
  }

  reset() {
    this.board = Array(9).fill('');
    this.currentPlayer = 'X';
    this.gameOver = false;
    this.winner = null;
  }
}

module.exports = XOGame;
