class LobbysController < WebsocketRails::BaseController
  def initialize_session
    logger.debug("initialize lobbys controller")
  end
  
  def login_user
    logger.debug("connected user #{message}")
    
  end
end
