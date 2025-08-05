// Import the XOGame class from server.js
const XOGame = require('../game/XOGame');

describe('Basic Tests', () => {
  test('should pass basic test', () => {
    expect(true).toBe(true);
  });

  test('should pass another basic test', () => {
    expect(1 + 1).toBe(2);
  });
}); 