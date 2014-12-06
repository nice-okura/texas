$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log 'Game Start'

  # ●を移動
  # @param [Array] users 旧当番ユーザと新当番ユーザのUserオブジェクトが入った要素数2の配列
  turn = (users) ->
    console.log 'turn'
    $('[data-user_id="' + users[0].user_id + '"]').children('.turn').html('')
    $('[data-user_id="' + users[1].user_id + '"]').children('.turn').html('●')

  # ボタンを表示
  # @param [int] id ボタンを表示するユーザのID
  show_buttons = (id) ->
    console.log 'show_buttons'
    my = $('.my_player')
    $('.buttons').show() if my.data('user_id') is id

  # ユーザ情報更新
  # @param [User] user 情報更新するユーザ
  update_user = (user) ->
    console.log 'update user: ' + user.name
    turn_user = $('[data-user_id="' + user.user_id + '"]')
    turn_user.children('.keep_tip').html('keep: $' + user.keep_tip)
    turn_user.children('.bet_tip').html('bet: $' + user.bet_tip)

  # 複数ユーザ情報更新
  # @param [Array] users 情報更新するユーザのUserオブジェクトが入った配列
  update_users = (users) ->
    console.log 'update users'
    $.each users, (i, user) ->
      update_user(user)
    
  # テーブル情報更新
  # @param [Table] table 情報更新するテーブル
  update_table = (table) ->
    console.log 'update table'
    console.log table.upcards
    # カードオープン
    $.each table.upcards, (i, s) ->
      num = parseInt(s)
      switch s.charAt(2)
        when 's'
          mark = '&spades;'
          color = 'card_black'
        when 'c'
          mark = '&clubs;'
          color = 'card_black'
        when 'h'
          mark = '&hearts;'
          color = 'card_red'
        when 'd'
          mark = '&diams;'
          color = 'card_red'
      card = $('[data-card_id="' + i + '"]')
      card.attr('class', color)
      card.html(num + '<br>' + mark)
    # チップ変更
    $('.table_tip').html('$' + table.tip)
  
  # 誰かがボタンを押した時
  # @param [Array] users 旧当番ユーザと新当番ユーザのUserオブジェクトが入った要素数2の配列
  action = (users) ->
    console.log 'action'
    update_user(users[0])
    turn(users)
    show_buttons(users[1].user_id)
    console.log '----------------'

  # success
  success = (res) ->
    console.log res

  # failure
  failure = (res) ->
    console.log res
    alert res[0]
    show_buttons(res[1])

  # 次のフェーズへ移行
  # @param [Array] turn_user_and_table 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  next_phase = (turn_user_and_table) ->
    console.log 'next_phase'
    turn_user = turn_user_and_table[0]
    table = turn_user_and_table[1]
    update_users(table.players)
    update_table(table)
    turn([turn_user, table.turn_user])
    show_buttons(table.turn_user.user_id)
    console.log table
  
  # イベントと関数の関連付け
  ws.bind 'action', action
  ws.bind 'next_phase', next_phase
  
  # ボタン押下時
  $("#call, #fold, #check, #bet, #raise").click ->
    console.log $(this).attr("id")
    $(".buttons").hide()
    ws.trigger $(this).attr("id"), $("#num").val(), success, failure
    return

  ws.close
    