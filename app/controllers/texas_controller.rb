# coding: utf-8
class TexasController < ApplicationController

  # 52枚のカード
  ALL_CARDS = ["01s", "02s", "03s", "04s", "05s", "06s",
    "07s", "08s", "09s", "10s", "11s", "12s", "13s",
    "01c", "02c", "03c", "04c", "05c", "06c",
    "07c", "08c", "09c", "10c", "11c", "12c", "13c",
    "01h", "02h", "03h", "04h", "05h", "06h",
    "07h", "08h", "09h", "10h", "11h", "12h", "13h",
    "01d", "02d", "03d", "04d", "05d", "06d",
    "07d", "08d", "09d", "10d", "11d", "12d", "13d"]

  def new
    logger.info "[#{self.class}][#{__method__}]"
    
    logger.debug "ゲーム開始(#{session[:user_name]})"
    logger.debug @my unless @my.nil?
    
    @login_users = Texas::Application.config.users

    logger.debug session
    logger.debug @login_users
    
    # 自分のユーザオブジェクト取得
    @my = @login_users.find { |user| user.user_id == session[:user_id] }
    
    if Texas::Application.config.table.nil?
      # 場(Table)がない場合、作成
      Texas::Application.config.table = Table.new(ALL_CARDS.shuffle, @my)
      print_debug 
    elsif Texas::Application.config.table.players.empty?
      # 場が作成されていて、
      # プレイヤーが誰もいなかった場合、初期化
      Texas::Application.config.table.reset!(ALL_CARDS.shuffle, @my)
    end
      
    @table = Texas::Application.config.table

    # Draw Cards for users who have no cards
    @login_users.each do |user|
      if @table.players.find { |player| player == user }.nil?
        # ユーザがプレイ中でなければ
        # 各人にカードを２枚ずつ配る
        user.hand = @table.draw_cards(2) if user.hand.nil?

        # ユーザ初期化
        user.keep_tip = 100
        user.bet_tip = 0
        user.fold_flg = false
        @table.add_user(user)
      end
    end

    # BTN, SB, BB, 当番を設定する
    if @table.btn.blank? then
      @table.btn = @my
      @table.sb = @table.next_user(@table.btn)
      @table.bb = @table.next_user(@table.sb)
      @table.turn_user = @table.next_user(@table.bb)

      logger.debug @table.turn_user
      # ブラインド
      @table.sb.gamble(1)
      @table.bb.gamble(2)
      @table.max_user = @table.bb
    end

    print_debug

    render 'texas'
  end
end
