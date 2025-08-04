#!/usr/bin/env node`
const { spawn } = require('child_process');
const http = require('http');

console.log('🔍 Starting test debug...');

// Test 1: Check if dependencies are installed
console.log('\n1. Checking dependencies...');
try {
  require('express');
  require('socket.io');
  require('jest');
  console.log('✅ All dependencies are available');
} catch (error) {
  console.log('❌ Missing dependency:', error.message);
}

// Test 2: Check if server can start
console.log('\n2. Testing server startup...');
const server = spawn('node', ['server.js'], {
  stdio: ['pipe', 'pipe', 'pipe']
});

let serverStarted = false;
let serverOutput = '';

server.stdout.on('data', (data) => {
  serverOutput += data.toString();
  if (serverOutput.includes('XO Game server running')) {
    serverStarted = true;
    console.log('✅ Server started successfully');
  }
});

server.stderr.on('data', (data) => {
  console.log('❌ Server error:', data.toString());
});

// Wait for server to start
setTimeout(() => {
  if (!serverStarted) {
    console.log('❌ Server failed to start within 10 seconds');
    console.log('Server output:', serverOutput);
  }
  
  // Test 3: Check health endpoint
  if (serverStarted) {
    console.log('\n3. Testing health endpoint...');
    const req = http.get('http://localhost:3000/health', (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          if (response.status === 'OK') {
            console.log('✅ Health endpoint working');
          } else {
            console.log('❌ Health endpoint returned unexpected response:', response);
          }
        } catch (error) {
          console.log('❌ Health endpoint returned invalid JSON:', data);
        }
        server.kill();
        process.exit(0);
      });
    });
    
    req.on('error', (error) => {
      console.log('❌ Health endpoint request failed:', error.message);
      server.kill();
      process.exit(1);
    });
    
    req.setTimeout(5000, () => {
      console.log('❌ Health endpoint request timed out');
      server.kill();
      process.exit(1);
    });
  } else {
    server.kill();
    process.exit(1);
  }
}, 10000);

// Kill server if script exits
process.on('SIGINT', () => {
  server.kill();
  process.exit(0);
}); 