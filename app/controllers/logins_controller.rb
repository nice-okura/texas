# coding: utf-8
class LoginsController < ApplicationController
  @@user_id = 0
  @@users = []

  def new
    session[:user_id] = nil
    session[:user_name] = nil
  end  
  
  def create
    name = params[:name]
    @@user_id = 1 if @@user_id.nil?
    @@users = [] if @@users.nil?
    logger.debug session

    if !name.empty? 
      # Userモデルを作成する。DB使わないならnewのみ
      user = User.new(user_id: @@user_id, name: name)
      @@user_id += 1
      @@users.push(user)
      @login_users = @@users
      session[:user_id] = user.user_id
      session[:user_name] = name

      # 他のログインしているユーザにユーザ情報を送信
      # broadcast_message(:login_users, {:user_name => name})

      render 'lobby'     
    else
      logger.debug '名前が入力されていない。'
      flash.now[:alert] = '名前を入力してください。'

      render 'new'
    end
  end
  
  def lobby
  end
end
