# coding: utf-8
class TexasController < ApplicationController
  def new
    logger.debug "ゲーム開始"
    @login_users = Texas::Application.config.users
    @my_id = session[:user_id]
    @my_name = session[:user_name]
    render 'texas'
  end
end
