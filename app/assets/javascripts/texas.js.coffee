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
    card_tag.attr('class', 'card_hidden')
    card_tag.html('　<br>　')
    card_tag = user_tag.children('[data-card_id="1"]')
    card_tag.attr('class', 'card_hidden')
    card_tag.html('　<br>　')
  
  # 誰かがボタンを押した時
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  action = (res) ->
    console.log 'action'

    turn_user = res[0]
    table = res[1].table
    hide_cards(turn_user) if turn_user.fold_flg
    update_user(turn_user)
    turn(turn_user, table.turn_user)
    show_buttons(table.turn_user.user_id, table.btns_flg)
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
    show_buttons(table.turn_user.user_id, table.btns_flg)

  # 次のフェーズへ移行
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  next_phase = (res) ->
    console.log 'next_phase'
    console.log res
    turn_user = res[0]
    table = res[1].table
    hide_cards(turn_user) if turn_user.fold_flg
    update_users(table.players)
    update_table(table)
    turn(turn_user, table.turn_user)
    show_buttons(table.turn_user.user_id, table.btns_flg)
    console.log table

  # 結果発表
  # @param [Array] res 旧当番ユーザのUserオブジェクトとTableオブジェクトが入った要素数2の配列
  finish = (res) ->
    console.log 'finish'
    console.log res

    turn_user = res[0]
    table = res[1].table
    hide_cards(turn_user) if turn_user.fold_flg

    # カードオープン
    $.each table.players, (i, u) ->
      return true if u.fold_flg

      $.each u.hand, (j, s) ->
        card_disp = decode_card(s)
        user_tag = $('[data-user_id="' + u.user_id + '"]')
        card_tag = user_tag.children('[data-card_id="' + j + '"]')
        card_tag.attr('class', card_disp.color)
        card_tag.html(card_disp.num + '<br>' + card_disp.mark)

    $('[data-user_id="' + turn_user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #C8C8C8')
    
    # 勝者を強調
    $.each table.winners, (i, winner) ->
      console.log winner.name
      $('[data-user_id="' + winner.user_id + '"]').css('background-color','#FDC44F')
      $('[data-user_id="' + winner.user_id + '"]').css('box-shadow','0px 0px 1px 3px #FDC44F')

    # Regameボタン表示
    $('.regame_buttons').show()

    update_users(table.players)
    update_table(table)      

  # テーブルのカードを伏せる
  close_cards = (table) -> 
    console.log 'CLOSE_CARDS'

    # テーブルのカードを伏せる
    for i in [0..4]
      card_tag = $('.table_cards').children('[data-card_id="' + i + '"]')
      card_tag.attr('class', 'card_ura')
      card_tag.empty()

    # 全ユーザのカードを伏せ、自分のカードはオープン
    $.each table.players, (i, player) ->
      if player.user_id == $('.my_player').data('user_id')
        my = player

        # 自分ならカードオープン
        $.each my.hand, (j, s) ->
          card_disp = decode_card(s)

          user_tag = $('[data-user_id="' + my.user_id + '"]')
          card_tag = user_tag.children('[data-card_id="' + j + '"]')
          card_tag.attr('class', card_disp.color)
          card_tag.html(card_disp.num + '<br>' + card_disp.mark)
      else
        for j in [0..1]
          user_tag = $('[data-user_id="' + player.user_id + '"]')
          card_tag = user_tag.children('[data-card_id="' + j + '"]')
          card_tag.attr('class', 'card_ura')
          #card_tag.empty()

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
    show_buttons(table.turn_user.user_id, table.btns_flg)

    # Regameボタン非表示
    $('.regame_buttons').hide()

    # 強調をやめる
    $.each table.players, (i, player) ->
      $('[data-user_id="' + player.user_id + '"]').css('box-shadow','0px 0px 1px 3px #C8C8C8')
      $('[data-user_id="' + player.user_id + '"]').css('background-color','#C8C8C8')

    # 当番の人を強調
    $('[data-user_id="' + turn_user.user_id + '"]').css('box-shadow','0px 0px 1px 3px #FDC44F')

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
