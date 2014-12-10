class ApplicationController < ActionController::Base
  protect_from_forgery

  def print_debug
    logger.debug '#'*50
    logger.debug "### PRINT_DEBUG #{'#'*34}"
    logger.debug '#'*50

    logger.debug "@login_users:"
    logger.debug @login_users
    logger.debug "Table:"
    logger.debug "#{Texas::Application.config.table.inspect}"

    logger.debug '#'*50
    logger.debug '#'*50
    logger.debug '#'*50
  end
end
