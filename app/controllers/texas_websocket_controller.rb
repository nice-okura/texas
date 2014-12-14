# coding: utf-8
class TexasWebsocketController < WebsocketRails::BaseController

  def initialize_session
    logger.debug("initialize texas websocket controller")
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
    if next_turn_user == table.max_user then
      if table.phase == "river"
        logger.debug("finish")
        broadcast_message "finish", table
      else
        logger.debug("next phase")
        table.next_phase()
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
    if next_turn_user == table.max_user then
      if table.phase == "river"
        logger.debug("finish")
        broadcast_message "finish", table
      else
        logger.debug("next phase")
        table.next_phase()
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
    
    raise_tip = message.to_i
    table = Texas::Application.config.table
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
    # 一周したら次のフェーズへ
    if next_turn_user == table.max_user then
      logger.debug("next phase")
      table.next_phase()
      broadcast_message "next_phase", [turn_user, table]
    else
      broadcast_message :action, [turn_user, table]
    end
  end

end
