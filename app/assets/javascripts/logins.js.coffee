$ -> 
  ws = new WebSocketRails('herpes.nagoya:3000/websocket', true)
  ws.trigger 'login_user'
  console.log('logout')