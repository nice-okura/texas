$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log('Game Start')

  # ボタン押下時
  $("#call, #fold, #check, #bet, #raise").click ->
    $(".buttons").hide()
    ws.trigger $(this).attr("id"), $("#num").val()
    console.log('buttontest')
    return

  #当番に●を表示
  turn = (message) ->
    $(".other_players,.my_player").each ->
      if $(this).attr("data-user_id") is message.toString()
        $(this).children(".turn").html("●")
        if $(this).attr("class") is "my_player"
          $(this).find("#call, #fold, #check, #bet, #raise").show()
      else
        $(this).children(".turn").html("")

  # buttontestイベント発生時は関数turnを実行
  ws.bind 'buttontest', turn
  
  ws.close
    