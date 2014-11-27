# coding: utf-8
class TexasController < ApplicationController

  # 場カード
  Texas::Application.config.cards = []

  def start
    logger.debug "ゲーム開始"
    # ゲームで使うカードをランダムに抽出
    all_cards = ["01s", "02s", "03s", "04s", "05s", "06s",
      "07s", "08s", "09s", "10s", "11s", "12s", "13s",
      "01c", "02c", "03c", "04c", "05c", "06c",
      "07c", "08c", "09c", "10c", "11c", "12c", "13c",
      "01h", "02h", "03h", "04h", "05h", "06h",
      "07h", "08h", "09h", "10h", "11h", "12h", "13h",
      "01d", "02d", "03d", "04d", "05d", "06d",
      "07d", "08d", "09d", "10d", "11d", "12d", "13d"]
    n = Texas::Application.config.users.size * 2 + 5
    cards = all_cards.sample(n)
    # 手札とチップを設定
    Texas::Application.config.users.each do |user|
      user.hand = cards.slice!(0,2)
      user.keep_tip = 100
      user.bet_tip = 0
    end
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
  end

end
