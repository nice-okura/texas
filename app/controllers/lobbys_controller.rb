class LobbysController < WebsocketRails::BaseController
  def initialize_session
    logger.debug("initialize lobbys controller")
  end
  
  def login_user
    logger.debug("connected user #{session[:user_name]}")

    if message == 'start'
      # ゲーム開始
      broadcast_message :login_user, 'start'
    else
      # ユーザログイン
      user_data = { 
        :my_name => session[:user_name],
        :users => Texas::Application.config.users.select { |user| user.name }
      }
      
      broadcast_message :login_user, user_data
    end
  end
end
