$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log 'Game Start'

  # ●を移動
  # @param [Array] users 旧当番ユーザと新当番ユーザのUserオブジェクトが入った要素数2の配列
  turn = (turn_user, next_turn_user) ->
    console.log 'turn'
    console.log next_turn_user
    $('[data-user_id="' + turn_user.user_id + '"]').children('.turn').html('')
    $('[data-user_id="' + next_turn_user.user_id + '"]').children('.turn').html('●')

  # ボタンを表示
  # @param [int] id ボタンを表示するユーザのID
  show_buttons = (id, btns_flg) ->
    console.log 'show_buttons'
    if btns_flg
      $('#call, #fold, #raise').show()
      $('#check, #bet').hide()
    else
      $('#check, #fold, #bet').show()
      $('#call, #raise').hide()
    $('.buttons').show() if $('.my_player').data('user_id') is id

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
    console.log users
    $.each users, (i, user) ->
      update_user(user)
    
  # テーブル情報更新
  # @param [Table] table 情報更新するテーブル
  update_table = (table) ->
    console.log 'update table'
    console.log table.upcards
    # カードオープン
    $.each table.upcards, (i, s) ->
      card_disp = decode_card(s)
      card_tag = $('.table_cards').children('[data-card_id="' + i + '"]')
      card_tag.attr('class', card_disp.color)
      card_tag.html(card_disp.num + '<br>' + card_disp.mark)
    # チップ変更
    $('.table_tip').html('$' + table.tip)

  # カードの数字＆マークを表示用に変換
  decode_card = (card) ->
    num = parseInt(card)
    switch card.charAt(2)
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
    return {num: num, mark: mark, color: color}
  
  # 誰かがボタンを押した時
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  action = (res) ->
    console.log 'action'
    turn_user = res[0]
    table = res[1].table
    update_user(turn_user)
    turn(turn_user, table.turn_user)
    show_buttons(table.turn_user.user_id, table.btns_flg)
    console.log '----------------'

  # success
  # 呼ばれることのない関数（いまんとこ）
  success = (res) ->
    console.log res

  # failure
  # @param [Array] res アラートで表示する文字列とtableオブジェクトが入った要素数2の配列
  failure = (res) ->
    console.log res
    msg = res[0]
    table = res[1].table
    alert msg
    show_buttons(table.turn_user.user_id, table.btns_flg)

  # 次のフェーズへ移行
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  next_phase = (res) ->
    console.log 'next_phase'
    turn_user = res[0]
    table = res[1].table
    console.log table
    console.log table.tip
    console.log table.bb
    console.log table.players
    update_users(table.players)
    update_table(table)
    turn(turn_user, table.turn_user)
    show_buttons(table.turn_user.user_id, table.btns_flg)
    console.log table

  # 結果発表
  finish = (res) ->
    console.log 'finish'
    table = res.table
    # カードオープン
    $.each table.players, (i, u) ->
      $.each u.hand, (j, s) ->
        card_disp = decode_card(s)
        user_tag = $('[data-user_id="' + u.user_id + '"]')
        card_tag = user_tag.children('[data-card_id="' + j + '"]')
        card_tag.attr('class', card_disp.color)
        card_tag.html(card_disp.num + '<br>' + card_disp.mark)

  # イベントと関数の関連付け
  ws.bind 'action', action
  ws.bind 'next_phase', next_phase
  ws.bind 'finish', finish
  
  # ボタン押下時
  $('#call, #fold, #check, #bet, #raise').click ->
    console.log $(this).attr("id")
    $('.buttons').hide()
    ws.trigger $(this).attr("id"), $('#num').val(), success, failure
    return

  ws.close
    