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
end
