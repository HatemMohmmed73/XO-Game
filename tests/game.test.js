// Import the XOGame class from server.js
const { XOGame } = require('../server');

describe('XOGame', () => {
  let game;

  beforeEach(() => {
    game = new XOGame();
  });

  test('should initialize with empty board', () => {
    expect(game.board).toEqual(Array(9).fill(''));
    expect(game.currentPlayer).toBe('X');
    expect(game.gameOver).toBe(false);
    expect(game.winner).toBeNull();
  });

  test('should make valid moves', () => {
    expect(game.makeMove(0)).toBe(true);
    expect(game.board[0]).toBe('X');
    expect(game.currentPlayer).toBe('O');
  });

  test('should not make moves on occupied cells', () => {
    game.makeMove(0);
    expect(game.makeMove(0)).toBe(false);
    expect(game.board[0]).toBe('X');
  });

  test('should not make moves when game is over', () => {
    // Create a winning scenario
    game.board = ['X', 'X', 'X', '', '', '', '', '', ''];
    game.gameOver = true;
    expect(game.makeMove(3)).toBe(false);
  });

  test('should detect horizontal win', () => {
    game.board = ['X', 'X', '', '', '', '', '', '', ''];
    game.currentPlayer = 'X';
    expect(game.makeMove(2)).toBe(true);
    expect(game.gameOver).toBe(true);
    expect(game.winner).toBe('X');
  });

  test('should detect vertical win', () => {
    game.board = ['X', '', '', 'X', '', '', '', '', ''];
    game.currentPlayer = 'X';
    expect(game.makeMove(6)).toBe(true);
    expect(game.gameOver).toBe(true);
    expect(game.winner).toBe('X');
  });

  test('should detect diagonal win', () => {
    game.board = ['X', '', '', '', 'X', '', '', '', ''];
    game.currentPlayer = 'X';
    expect(game.makeMove(8)).toBe(true);
    expect(game.gameOver).toBe(true);
    expect(game.winner).toBe('X');
  });

  test('should detect draw', () => {
    game.board = ['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', ''];
    game.currentPlayer = 'O';
    expect(game.makeMove(8)).toBe(true);
    expect(game.gameOver).toBe(true);
    expect(game.winner).toBe('draw');
  });

  test('should alternate players', () => {
    expect(game.currentPlayer).toBe('X');
    game.makeMove(0);
    expect(game.currentPlayer).toBe('O');
    game.makeMove(1);
    expect(game.currentPlayer).toBe('X');
  });

  test('should reset game', () => {
    game.board = ['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', 'O'];
    game.currentPlayer = 'O';
    game.gameOver = true;
    game.winner = 'draw';
    
    game.reset();
    
    expect(game.board).toEqual(Array(9).fill(''));
    expect(game.currentPlayer).toBe('X');
    expect(game.gameOver).toBe(false);
    expect(game.winner).toBeNull();
  });
}); 