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
    logger.debug "ゲーム開始(#{session[:user_name]})"
    
    @login_users = Texas::Application.config.users

    logger.debug session
    logger.debug @login_users
    
    # 自分のユーザオブジェクト取得
    @my = @login_users.find { |user| user.user_id == session[:user_id] }
    
    # 場(Table)がない場合、作成
    Texas::Application.config.table = Table.new(ALL_CARDS.shuffle, @my) if Texas::Application.config.table.nil?
    @table = Texas::Application.config.table

    # Draw Cards for users who have no cards
    @login_users.each do |user|
      user.hand = @table.get_cards(2) if user.hand.nil?
      user.keep_tip = 100
      user.bet_tip = 0
    end
   
    logger.debug @table.omote

    render 'texas'
  end
end

# 場クラス
class Table
  attr_accessor :omote, :cards, :phase, :tip, :turn_user, :open_cards
  PREFLOP = "preflop"
  
  # コンストラクタ
  # @param [Array] all_cards この場で使用する全カード
  # @param [User] turn_user １番初めの当番ユーザ
  def initialize(all_cards, turn_user)
    @phase = PREFLOP
    @cards = all_cards
    @tip = 0
    @turn_user = turn_user
    @omote = 2 # TODO: 数字より表になっているカードの配列の方が、後々勝利判定するときに便利そう
    @open_cards = []
  end

  # ユーザ追加
  def add_user(user)
    @players << user
  end

  # 場からカードをnum枚引く
  def get_cards(num)
    return @cards.slice!(0..num-1)
  end

end

