$ ->
  # ログアウトしてこのページに遷移した時、全ユーザにログインユーザ情報を送信
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user'
  console.log('Game Start')








