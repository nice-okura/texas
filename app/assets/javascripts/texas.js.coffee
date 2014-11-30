$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log('Game Start')

  # ボタン押下時
  $("#buttontest").click ->
    $("#buttontest").hide()
    ws.trigger 'buttontest', 'test'
    console.log('buttontest')
    return

  #当番に●を表示
  turn = (message) ->
    $(".other_players,.my_player").each ->
      if $(this).attr("data-user_id") is message.toString()
        $(this).children(".turn").html("●")
        if $(this).attr("class") is "my_player"
          $(this).find("#buttontest").show()
      else
        $(this).children(".turn").html("")

  # サーバからイベントを受信したときに実行する関数を指定
  ws.bind 'buttontest', turn
  
  ws.close
    