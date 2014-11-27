# coding: utf-8
class TexasController < ApplicationController
<<<<<<< HEAD
    # 52枚のカード
    ALL_CARDS = ["01s", "02s", "03s", "04s", "05s", "06s",
=======

  # 場カード
  Texas::Application.config.cards = []

  def start
    logger.debug "ゲーム開始"
    # ゲームで使うカードをランダムに抽出
    all_cards = ["01s", "02s", "03s", "04s", "05s", "06s",
>>>>>>> cf47769b210b4296ff2175a439649c37be7d8c55
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
    end
   
    logger.debug @table.omote
=begin    
    n = Texas::Application.config.users.size * 2 + 5
    cards = all_cards.sample(n)
    # 手札とチップを設定
    Texas::Application.config.users.each do |user|
      # 各ユーザにカードを配る
      user.hand = cards.slice!(0,2)
      user.keep_tip = 100
      user.bet_tip = 0
    end
<<<<<<< HEAD

    @table_id = 0            # 場ID
    @table_phase = "preflop" # ラウンド種類
    @table_cards = cards     # 場カード
    @table_omote = 0         # 表にする場カードの枚数
    @table_tip = 0           # 場チップ
    @table_turn = 0          # 当番ID
=end

    render 'texas'
  end
end

# 場クラス
class Table
  attr_accessor :omote, :cards, :phase, :tip, :turn_user

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
  end

  # ユーザ追加
  def add_user(user)
    @players << user
  end

  # 場からカードをnum枚引く
  def get_cards(num)
    return @cards.slice!(0..num-1)
=======
    Texas::Application.config.cards = cards

    @login_users = Texas::Application.config.users
    @my_id = session[:user_id]
    @my_name = session[:user_name]
    @table_cards = Texas::Application.config.cards  # 場カード
    @table_omote = 0                                # 表にする場カードの枚数
    @table_tip = 0                                  # 場チップ
    @table_turn = 0                                 # 当番ID
    render 'texas'
  end

  def started
    @login_users = Texas::Application.config.users
    @my_id = session[:user_id]
    @my_name = session[:user_name]
    @table_cards = Texas::Application.config.cards  # 場カード
    @table_omote = 0                                # 表にする場カードの枚数
    @table_tip = 0                                  # 場チップ
    @table_turn = 0                                 # 当番ID
    render 'texas'
>>>>>>> cf47769b210b4296ff2175a439649c37be7d8c55
  end

end
