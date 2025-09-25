// websocket_server.js
const WebSocket = require('ws');
const http = require('http');

// Change to match your backend endpoint if you also want to save messages
// const axios = require('axios'); // Uncomment if you plan to POST to PHP/DB

const PORT = 8080;
const server = http.createServer();
const wss = new WebSocket.Server({ server });

/**
 * Map of connected clients
 * key: userId (int or string)
 * value: WebSocket instance
 */
const clients = new Map();

wss.on('connection', (ws) => {
  console.log('New client connected');

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      console.log('Received:', data);

      switch (data.type) {
        case 'register':
          // Save user socket
          ws.userId = data.userId;
          clients.set(data.userId, ws);
          console.log(`User ${data.userId} registered`);
          break;

        case 'message':
          // Optionally persist to DB/PHP
          /*
          axios.post('https://your-api/send_message.php', {
            from_user: data.from_user,
            to_user: data.to_user,
            message: data.message
          }).catch(err => console.error('DB save error:', err));
          */

          // Broadcast to BOTH sender and recipient
          broadcastToUsers([data.to_user, data.from_user], {
            type: 'message',
            from_user: data.from_user,
            to_user: data.to_user,
            message: data.message,
            timestamp: data.timestamp || new Date().toISOString()
          });
          break;

        case 'typing':
          // Notify the other user only
          broadcastToUsers([data.to_user], {
            type: 'typing',
            from_user: data.from_user,
            isTyping: data.isTyping
          });
          break;

        default:
          console.log('Unknown type:', data.type);
      }
    } catch (err) {
      console.error('Invalid JSON:', err);
    }
  });

  ws.on('close', () => {
    if (ws.userId) {
      clients.delete(ws.userId);
      console.log(`User ${ws.userId} disconnected`);
    }
  });
});

function broadcastToUsers(userIds, payload) {
  const msg = JSON.stringify(payload);
  userIds.forEach((id) => {
    const client = clients.get(id);
    if (client && client.readyState === WebSocket.OPEN) {
      client.send(msg);
    }
  });
}

server.listen(PORT, () => {
  console.log(`✅ WebSocket server running on ws://localhost:${PORT}`);
});
