class ChatController < WebsocketRails::BaseController	
  def initialize_session
    p "FASFAFSAFSF"
    logger.debug "Session Initialized\n"
  end

  def receive_message
    # messageという変数が送られてくる
    logger.debug "call new_message: #{message}"
    broadcast_message :receive_message, message
  end
end
