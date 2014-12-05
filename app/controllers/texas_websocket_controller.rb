# coding: utf-8
class TexasWebsocketController < WebsocketRails::BaseController

  def initialize_session
    logger.debug("initialize texas websocket controller")
  end
  
  def out_player
    logger.debug("受信メッセージ:" + message)

    user_id = message.io_i
    Texas::Application.config.table.player.reject! { |player| player.user_id == user_id }
  end

  def call
    logger.debug("call")
    user = Texas::Application.config.table.turn_user
    user.call()
    next_user = Texas::Application.config.table.turn()
    broadcast_message "action", [user, next_user]
  end

  def fold
    logger.debug("fold")
    user = Texas::Application.config.table.turn_user
    user.fold()
    next_user = Texas::Application.config.table.turn()
    broadcast_message "action", [user, next_user]
  end

  def check
    logger.debug("check")
    user = Texas::Application.config.table.turn_user
    user.check()
    next_user = Texas::Application.config.table.turn()
    broadcast_message "action", [user, next_user]
  end

  def bet
    logger.debug("bet")
    user = Texas::Application.config.table.turn_user
    user.bet(message.to_i)
    next_user = Texas::Application.config.table.turn()
    broadcast_message "action", [user, next_user]
  end

  def raise
    logger.debug("raise")
    user = Texas::Application.config.table.turn_user
    user.raise(message.to_i)
    next_user = Texas::Application.config.table.turn()
    broadcast_message "action", [user, next_user]
  end
  
end
