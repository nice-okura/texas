# coding: utf-8
class LoginsController < ApplicationController
  @@user_id = 0
  @@users = []

  def new
    if session[:user_id]
      logger.debug @@users
      logger.debug session

      if @@users.empty?       
        # ユーザをDBに保存していないので、sessionが残ったまま
        # アプリが再起動したりして@@usersが消えた場合は、
        # ログアウト処理を行う
        session[:user_id] = nil
        session[:user_name] = nil
      else
        @login_users = @@users
        logger.debug @login_users
        render 'lobby'
        end
    end
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

      logger.debug session
      logger.debug @@users
      logger.debug @login_users

      render 'lobby'
    else
      logger.debug '名前が入力されていない。'
      flash.now[:alert] = '名前を入力してください。'

      render 'new'
    end
  end

  def destroy
    # usersからユーザ名除去
    @@users.delete(session[:user_name])

    logger.debug "users: #{@@users}"

    session[:user_id] = nil
    session[:user_name] = nil


    render 'new'
  end
  
  def lobby
  end
end
