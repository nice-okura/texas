# coding: utf-8
class LoginsController < ApplicationController
  @@user_id = 0
  Texas::Application.config.users = []

  def new
    logger.info "[#{self.class}][#{__method__}]"
    
    if session[:user_id]
      logger.debug Texas::Application.config.users
      logger.debug session

      if Texas::Application.config.users.empty?       
        # ユーザをDBに保存していないので、sessionが残ったまま
        # アプリが再起動したりしてTexas::Application.config.usersが消えた場合は、
        # ログアウト処理を行う
        session[:user_id] = nil
        session[:user_name] = nil
      else
        @login_users = Texas::Application.config.users
        logger.debug @login_users
        render 'lobby'
      end
    end
  end
  
  def create
    logger.debug "users: #{Texas::Application.config.users}"
    logger.debug session

    name = params[:name]
    if session[:user_name] == name
      logger.debug "リロード"
      @login_users = Texas::Application.config.users
      render 'lobby'
      return 
    end

    if !name.empty?
      # Userモデルを作成する。DB使わないならnewのみ
      logger.debug "User作成"
      user = User.new(user_id: @@user_id, name: name)
      @@user_id += 1
      Texas::Application.config.users.push(user)
      @login_users = Texas::Application.config.users
      session[:user_id] = user.user_id
      session[:user_name] = name

      # 他のログインしているユーザにユーザ情報を送信
      # broadcast_message(:login_users, {:user_name => name})

      logger.debug "users: #{Texas::Application.config.users}"
      logger.debug "login_users: #{@login_users}"
      
      if Texas::Application.config.users.empty?
        flash.now[:alert] = 'ログインしているユーザがいません。'
        render 'new'
        return
      end

      render 'lobby'
    else
      logger.debug '名前が入力されていない。'
      flash.now[:alert] = '名前を入力してください。'

      render 'new'
    end

    print_debug
  end

  def destroy
    # table.playersからユーザ除去
    if Texas::Application.config.table.present?
      logger.debug "table.playersからユーザ除去"
      table = Texas::Application.config.table
      users = Texas::Application.config.users
      table.out_user(users.find { |user| user.user_id == session[:user_id] })
      logger.debug "#{users.find { |user| user.user_id == session[:user_id] }}"
      logger.debug "table.players: #{Texas::Application.config.table.players}"
    end
    
    # usersからユーザ名除去
    Texas::Application.config.users.each do |user|
      if user.name == session[:user_name]
        Texas::Application.config.users.delete(user)
        break
      end
    end

    logger.debug "users: #{Texas::Application.config.users}"

    session[:user_id] = nil
    session[:user_name] = nil

    print_debug
   
    render 'new'
  end
  
  def all_logout
    # デバッグ用
    # sessionからユーザ情報を削除
    # config.usersからユーザ情報削除
    session[:user_name] = nil
    session[:user_id] = nil

    # table.playersをnilにする

      Texas::Application.config.table = nil


    Texas::Application.config.users = []

    render 'new'
  end

  def lobby
    logger.debug "LOBBY"
    logger.debug Texas::Application.config.users
  end
end
