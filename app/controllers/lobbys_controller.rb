class LobbysController < WebsocketRails::BaseController
  def initialize_session
    logger.debug("initialize lobbys controller")
  end
  
  def login_user
    logger.debug("connected user #{session[:user_name]}")

    user_data = { 
      :my_name => session[:user_name],
      :users => Texas::Application.config.users.select { |user| user.name }
    }

    broadcast_message :login_user, user_data
  end
end
