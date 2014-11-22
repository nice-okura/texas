class LobbysController < WebsocketRails::BaseController
  def initialize_session
    logger.debug("initialize lobbys controller")
  end
  
  def login_user
    logger.debug("connected user #{session[:user_name]}")

    broadcast_message :login_user, session[:user_name]
  end
end
