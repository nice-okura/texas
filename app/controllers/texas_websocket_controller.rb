# coding: utf-8
class TexasWebsocketController < WebsocketRails::BaseController

  def initialize_session
    logger.debug("initialize texas websocket controller")

    table = Texas::Application.config.table
    turn_user = table.turn_user
    broadcast_message :action, [turn_user, table]
  end
  
  def out_player
    logger.info "[#{self.class}][#{__method__}]"

    logger.debug("受信メッセージ:" + message)
    user_id = message.to_i
    Texas::Application.config.table.player.reject! { |player| player.user_id == user_id }
  end

  # call
  def call
    logger.info "[#{self.class}][#{__method__}]"

    table = Texas::Application.config.table
    turn_user = table.turn_user
    turn_user.call()
    next_turn_user = table.turn()

    # 一周したら次のフェーズへ
    if next_turn_user == table.max_user
      logger.debug("next phase")
      table.next_phase()

      if table.phase == "finish"
        logger.debug("finish")
        broadcast_message "finish", [turn_user, table]
      else
        print_debug
        broadcast_message "next_phase", [turn_user, table]
      end
    else
      broadcast_message :action, [turn_user, table]
    end
  end

  # check
  def check
    logger.info "[#{self.class}][#{__method__}]"
    
    table = Texas::Application.config.table
    turn_user = table.turn_user
    turn_user.check()
    next_turn_user = table.turn()

    # 一周したら次のフェーズへ
    if next_turn_user == table.max_user
      logger.debug("next phase")
      table.next_phase()

      if table.phase == "finish"
        logger.debug("finish")
        broadcast_message "finish", [turn_user, table]
      else
        print_debug
        broadcast_message "next_phase", [turn_user, table]
      end
    else
      broadcast_message :action, [turn_user, table]
    end
  end

  # raise
  # message: レイズする金額
  def raise
    logger.info "[#{self.class}][#{__method__}]"
    
    table = Texas::Application.config.table

    raise_tip = message.to_i
    turn_user = table.turn_user
    gap = table.max_user.bet_tip - turn_user.bet_tip
    
    if raise_tip > gap
      turn_user.raise(raise_tip)
      next_turn_user = table.turn()

      broadcast_message :action, [turn_user, table]
    else
      trigger_failure ["$#{(gap + 1)}以上でレイズしてね", table]
    end
  end
  
  # bet
  # message: ベットする金額
  def bet
    logger.info "[#{self.class}][#{__method__}]"

    table = Texas::Application.config.table
    turn_user = table.turn_user
    turn_user.bet(message.to_i)
    next_turn_user = table.turn()

    broadcast_message :action, [turn_user, table]
  end

  # fold
  def fold
    logger.info "[#{self.class}][#{__method__}]"
    
    table = Texas::Application.config.table
    turn_user = table.turn_user
    turn_user.fold()

    next_turn_user = table.turn()

    # foldしてないユーザが１人になった場合、
    # その場でゲーム終了
    if table.players.select { |user| !user.fold_flg }.size == 1
      logger.debug "foldして、残りのユーザ(#{next_turn_user})が一人になった"

      # おしまい
      table.phase = "finish"
      
      # チップ回収
      table.collect_tip

      # 勝者にあげる
      table.winners = [next_turn_user]
      table.winners.last.keep_tip += table.tip

      broadcast_message "finish", [turn_user, table]

      return 
    end

    # 一周したら次のフェーズへ
    if next_turn_user == table.max_user
      logger.debug("next phase")

      table.next_phase()

      if table.phase == "finish"
        logger.debug("finish")

        broadcast_message "finish", [turn_user, table]
      else
        print_debug

        broadcast_message "next_phase", [turn_user, table]
      end
    else
      broadcast_message :action, [turn_user, table]
    end
  end

  # もう一度プレイする
  def regame
    logger.info "[#{self.class}][#{__method__}]"

    table = Texas::Application.config.table
    login_users = Texas::Application.config.users

    # 自分のユーザオブジェクト取得
    my = login_users.find { |user| user.user_id == session[:user_id] }

    # テーブルの初期化
    table.reset!(TexasController::ALL_CARDS.shuffle, my)

    # ユーザにトランプを配る
    login_users.each do |user|
      # 各人にカードを２枚ずつ配る
      user.hand = table.draw_cards(2)
 
     # ユーザ初期化
      user.bet_tip = 0
      user.fold_flg = false
      table.add_user(user)
    end

    # BTN, SB, BB, 当番を設定する
    table.btn = table.next_user(table.btn)
    table.sb = table.next_user(table.btn)
    table.bb = table.next_user(table.sb)
    table.turn_user = table.next_user(table.bb)
    
    logger.debug table.turn_user

    # ブラインド
    table.sb.gamble(1)
    table.bb.gamble(2)
    table.max_user = table.bb

    broadcast_message :regame, [table.turn_user, table]
  end
  
  # デバッグ用
  def all_logout
    logger.info "[#{self.class}][#{__method__}]"
    
    broadcast_message :all_logout, []
  end

end
