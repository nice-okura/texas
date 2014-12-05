$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log('Game Start')

  # ボタン押下時
  $("#call, #fold, #check, #bet, #raise").click ->
    $(".buttons").hide()
    ws.trigger $(this).attr("id"), $("#num").val()
    console.log($(this).attr("id"))
    return

  # ●を移動
  turn = (users) ->
    console.log('turn')
    turn_user = $('[data-user_id="' + users[0].user_id + '"]')
    turn_user.children('.turn').html('')
    next_turn_user = $('[data-user_id="' + users[1].user_id + '"]')
    next_turn_user.children('.turn').html('●')

  # ボタンを表示
  show_buttons = (id) ->
    console.log('show_buttons')
    my = $('.my_player')
    $('.buttons').show() if my.data('user_id') is id

  # action
  action = (users) ->
    console.log('action')
    turn_user = $('[data-user_id="' + users[0].user_id + '"]')
    turn_user.children('.keep_tip').html('keep: $' + users[0].keep_tip)
    turn_user.children('.bet_tip').html('bet: $' + users[0].bet_tip)
    turn(users)
    show_buttons(users[1].user_id)

  # buttontestイベント発生時は関数turnを実行
  ws.bind 'action', action
  
  ws.close
    