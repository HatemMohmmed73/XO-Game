const request = require('supertest');
const { app } = require('../server');

// Set test port to avoid conflicts
process.env.PORT = 3001;

describe('Server Endpoints', () => {
  test('GET /health should return OK status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty('status', 'OK');
    expect(response.body).toHaveProperty('timestamp');
  });

  test('GET / should serve the game page', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.text).toContain('XO Game');
  });

  test('GET /style.css should serve CSS file', async () => {
    const response = await request(app).get('/style.css');
    expect(response.status).toBe(200);
    expect(response.headers['content-type']).toContain('text/css');
  });

  test('GET /script.js should serve JavaScript file', async () => {
    const response = await request(app).get('/script.js');
    expect(response.status).toBe(200);
    expect(response.headers['content-type']).toContain('application/javascript');
  });
}); 