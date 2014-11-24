$ -> 
  # ログアウトしてこのページに遷移した時、全ユーザにログインユーザ情報を送信
  ws = new WebSocketRails('herpes.nagoya:3000/websocket', true)
  ws.trigger 'login_user'
  console.log('logout')