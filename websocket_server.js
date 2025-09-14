const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080, host: '0.0.0.0' });

let clients = new Map(); // Map userId to ws connection

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    try {
      const data = JSON.parse(message);
      if (data.type === 'register') {
        // Register user connection
        clients.set(data.userId, ws);
        console.log(`User ${data.userId} connected`);
      } else if (data.type === 'message') {
        // Send message to recipient if connected
        const toUserWs = clients.get(data.to_user);
        if (toUserWs && toUserWs.readyState === WebSocket.OPEN) {
          toUserWs.send(JSON.stringify(data));
        }
        // Send back to sender to confirm delivery
        const fromUserWs = clients.get(data.from_user);
        if (fromUserWs && fromUserWs.readyState === WebSocket.OPEN) {
          fromUserWs.send(JSON.stringify(data));
        }
        console.log(`Message from ${data.from_user} to ${data.to_user}: ${data.message}`);
      } else if (data.type === 'typing') {
        // Forward typing status to recipient
        const toUserWs = clients.get(data.to_user);
        if (toUserWs && toUserWs.readyState === WebSocket.OPEN) {
          toUserWs.send(JSON.stringify(data));
        }
      }
    } catch (e) {
      console.error('Invalid message', e);
    }
  });

  ws.on('close', () => {
    // Remove disconnected client
    for (let [userId, clientWs] of clients.entries()) {
      if (clientWs === ws) {
        clients.delete(userId);
        console.log(`User ${userId} disconnected`);
        break;
      }
    }
  });
});

console.log('WebSocket server running on ws://0.0.0.0:8080');
