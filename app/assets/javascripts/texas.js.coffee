$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log('Game Start')

  # ボタン押下時
  $("#buttontest").click ->
    ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
    ws.trigger 'buttontest', 'test'
    console.log('buttontest')
    return

  #当番に●を表示
  turn = (message) ->
    console.log("message: " + message)
    $(".other_players,.my_player").each ->
      console.log($(this).attr("data-user_id"))
      if $(this).attr("data-user_id") is message.toString()
        $(this).children(".turn").html("●")
      else
        $(this).children(".turn").html("")
    return

  # サーバからイベントを受信したときに実行する関数を指定
  ws.bind 'buttontest', turn
  
  ws.close
    