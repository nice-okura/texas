$ ->
  # ゲーム開始
  ws = new WebSocketRails(location.hostname + ':' + location.port + '/websocket', true)
  ws.trigger 'login_user', 'start'
  console.log 'Game Start'

  # 現在のプレイヤーを強調
  # @param [Array] users 旧当番ユーザと新当番ユーザのUserオブジェクトが入った要素数2の配列
  turn = (turn_user, next_turn_user) ->
    console.log 'turn'
    console.log next_turn_user

    $('[data-user_id="' + turn_user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #C8C8C8')
    $('[data-user_id="' + next_turn_user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #FDC44F')

  # ボタンを表示
  # @param [int] id ボタンを表示するユーザのID
  # @param [Boolean] btns_flg ボタン表示パターン判別用フラグ
  show_buttons = (id, btns_flg, max_users_bet_tip, turn_users_bet_tip) ->
    console.log 'show_buttons'

    # レイズorベットの最少額を設定
    raise_min = max_users_bet_tip - turn_users_bet_tip + 1
    $('#num').attr('min', raise_min).val(raise_min)

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

    # keepとbetを更新
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
    delay = 0

    # カードオープン
    $.each table.upcards, (i, s) ->
      card_tag = $('.table_cards').children('[data-card_id="' + i + '"]')
      if card_tag.hasClass('opened')
        return true
      card_disp = decode_card(s)
      card_tag.children('.card_omote').attr('class', 'card_omote ' + card_disp.color)
      card_tag.children('.card_omote').html(card_disp.num + '<br>' + card_disp.mark)
      setTimeout (-> card_tag.addClass('opened')), delay
      delay += 1000

    # チップ変更
    $('.table_tip').html('$' + table.tip)

    return delay

  # カードの数字＆マークを表示用に変換
  decode_card = (card) ->
    num = parseInt(card)
    switch num
      when 1
        num = 'A'
      when 11
        num = 'J'
      when 12
        num = 'Q'
      when 13
        num = 'K'
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

  # カードを非表示にする
  hide_cards = (user) ->
    console.log 'hide_cards'
    user_tag = $('[data-user_id="' + user.user_id + '"]')
    card_tag = user_tag.children('[data-card_id="0"]')
    card_tag.addClass('folded')
    card_tag.children('div').hide()
    card_tag = user_tag.children('[data-card_id="1"]')
    card_tag.addClass('folded')
    card_tag.children('div').hide()
  
  # 誰かがボタンを押した時
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  action = (res) ->
    console.log 'action'

    turn_user = res[0]
    table = res[1].table
    hide_cards(turn_user) if turn_user.fold_flg
    update_user(turn_user)
    turn(turn_user, table.turn_user)
    show_buttons(table.turn_user.user_id, table.btns_flg, table.max_user.bet_tip, table.turn_user.bet_tip)
    console.log table
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
    show_buttons(table.turn_user.user_id, table.btns_flg, table.max_user.bet_tip, table.turn_user.bet_tip)

  # 次のフェーズへ移行
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  next_phase = (res) ->
    console.log 'next_phase'
    console.log res
    turn_user = res[0]
    table = res[1].table
    hide_cards(turn_user) if turn_user.fold_flg
    update_users(table.players)
    delay = update_table(table)
    setTimeout ->
      turn(turn_user, table.turn_user)
      show_buttons(table.turn_user.user_id, table.btns_flg, table.max_user.bet_tip, table.turn_user.bet_tip)
    , delay 
    console.log table

  # 結果発表
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  finish = (res) ->
    console.log 'finish'
    console.log res

    turn_user = res[0]
    table = res[1].table
    hide_cards(turn_user) if turn_user.fold_flg

    # 1人以外全員フォールドだったらカードオープンしない
    open_flg = $.grep(table.players, (u, i) -> !u.fold_flg).length != 1

    # カードオープン
    if open_flg
      $.each table.players, (i, u) ->
        return true if u.fold_flg
        $.each u.hand, (j, s) ->
          user_tag = $('[data-user_id="' + u.user_id + '"]')
          card_tag = user_tag.children('[data-card_id="' + j + '"]')
          card_disp = decode_card(s)
          card_tag.children('.card_omote').attr('class', 'card_omote ' + card_disp.color)
          card_tag.children('.card_omote').html(card_disp.num + '<br>' + card_disp.mark)
          card_tag.addClass('opened')

    $('[data-user_id="' + turn_user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #C8C8C8')

    if open_flg then delay = 1000 else delay = 0
    
    setTimeout ->
      # 勝者を強調
      $.each table.winners, (i, winner) ->
        console.log "WINNER:" + winner.user.name
        $('[data-user_id="' + winner.user.user_id + '"]').css('background-color','#FDC44F')
        $('[data-user_id="' + winner.user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #FDC44F')

        # 役を表示
        my_user_id = $('.my_player').data('user_id')
        if my_user_id == winner.user.user_id
          $('.hand_name').html(get_hand_name(winner.point))

      # Regameボタン表示
      $('.regame_buttons').show()

      # 勝者がチップGET
      update_users(table.players)
      update_table(table)      

    , delay

  # 役名を返す
  get_hand_name = (point) ->
    hand_name = ""

    switch point
      when 8
        hand_name = "STRAIGHT FLUSH"
      when 7
        hand_name = "FOUR OF A KIND"
      when 6
        hand_name = "FULL HOUSE"
      when 5
        hand_name = "FLUSH"
      when 4
        hand_name = "STRAIGHT"
      when 3
        hand_name = "THREE OF A KIND"
      when 2
        hand_name = "TWO PAIR"
      when 1
        hand_name = "ONE PAIR"
      else
        hand_name = "BUTA"

    return hand_name

  # テーブルのカードを伏せる
  close_cards = (table) -> 
    console.log 'CLOSE_CARDS'

    # テーブルのカードを伏せる
    for i in [0..4]
      card_tag = $('.table_cards').children('[data-card_id="' + i + '"]')
      card_tag.removeClass('opened')

    # 全ユーザのカードを伏せ、自分のカードはオープン
    $.each table.players, (i, player) ->
      role = ''
      role += '&#9401; ' if player.user_id == table.btn.user_id
      role += '&#9416; ' if player.user_id == table.sb.user_id
      role += '&#9399; ' if player.user_id == table.bb.user_id
      user_tag = $('[data-user_id="' + player.user_id + '"]')
      user_tag.children('span.role').html(role)

      # 自分ならカードオープン、他プレーヤーならカードを伏せる
      if player.user_id == $('.my_player').data('user_id')
        my = player
        $.each my.hand, (j, s) ->
          card_tag = $('.my_player').children('[data-card_id="' + j + '"]')
          card_disp = decode_card(s)
          card_tag.children('.card_omote').attr('class', 'card_omote ' + card_disp.color)
          card_tag.children('.card_omote').html(card_disp.num + '<br>' + card_disp.mark)
          card_tag.attr('class', 'card opened')
          card_tag.children('div').show()
      else
        for j in [0..1]
          card_tag = user_tag.children('[data-card_id="' + j + '"]')
          card_tag.attr('class', 'card')
          card_tag.children('div').show()

  # Regame時の処理
  regame = (res) ->
    console.log 'REGAME'
    console.log res

    turn_user = res[0]
    table = res[1].table

    # ユーザ表示更新
    update_users(table.players)

    # テーブル表示更新
    update_table(table)

    # Call等のボタン表示
    show_buttons(table.turn_user.user_id, table.btns_flg, table.max_user.bet_tip, table.turn_user.bet_tip)

    # Regameボタン非表示
    $('.regame_buttons').hide()

    # 強調をやめる
    $.each table.players, (i, player) ->
      $('[data-user_id="' + player.user_id + '"]').css('box-shadow','0px 0px 1px 3px #C8C8C8')
      $('[data-user_id="' + player.user_id + '"]').css('background-color','#C8C8C8')

    # 当番の人を強調
    $('[data-user_id="' + turn_user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #FDC44F')
    
    # 役の表示を消す
    $('.hand_name').html('')

    # カードを伏せる
    close_cards(table)

    console.log table

  # イベントと関数の関連付け
  ws.bind 'action', action
  ws.bind 'next_phase', next_phase
  ws.bind 'finish', finish
  ws.bind 'regame', regame
  
  # ボタン押下時
  $('#call, #fold, #check, #bet, #raise, #regame').click ->
    console.log $(this).attr("id")
    
    $('.buttons').hide()
    $('.regame_buttons').hide()
    
    ws.trigger $(this).attr("id"), $('#num').val(), success, failure
  
    return

  ##################################################################
  #
  # デバッグ用
  #
  ##################################################################
  all_logout = (res) ->
    console.log "ALL_LOGOUT"

    location.href = '/'

  $('#all_logout').click -> 
    ws.trigger 'all_logout', ''
    
    return

  ws.bind 'all_logout', all_logout

  ws.close
