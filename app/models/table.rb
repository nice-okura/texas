# -*- coding: utf-8 -*-
class Table
  include ActiveAttr::Model

  attribute :upcards
  attribute :cards
  attribute :phase
  attribute :tip
  attribute :turn_user
  attribute :players
  attribute :btn
  attribute :sb
  attribute :bb
  attribute :max_user
  attribute :btns_flg
  attr_accessor :upcards, :cards, :phase, :tip, :turn_user, :players, :btn, :sb, :bb, :max_user, :btns_flg

  MAX_OPEN_CARD = 5
  PREFLOP = "preflop" # 0枚オープン
  FLOP = "flop"       # 3枚オープン
  TURN = "turn"       # 4枚オープン
  RIVER = "river"     # 5枚オープン
  
  # コンストラクタ
  # @param [Array] all_cards この場で使用する全カード
  # @param [User] turn_user １番初めの当番ユーザ
  def initialize(all_cards, turn_user)
    logger.info "[#{self.class}][#{__method__}]"

    super

    @phase = PREFLOP
    @cards = all_cards
    @tip = 0
    @upcards = []
    @players = []
    @max_user = 0
    @btns_flg = true
  end

  # 初期化
  def reset!(all_cards, turn_user)
    logger.info "[#{self.class}][#{__method__}]"

    @phase = PREFLOP
    @cards = all_cards
    @tip = 0
    @upcards = []
    @players = []
    @sb = nil
    @bb = nil
    @btn = nil
    @turn_user = nil
  end

  # ユーザ追加
  def add_user(user)
    logger.info "[#{self.class}][#{__method__}]"

    @players << user
  end

  # ユーザ退室
  def out_user(user)
    logger.info "[#{self.class}][#{__method__}]"

    # 登板の人が抜けたら、ターンユーザを隣の人に変える
    if @turn_user == user and @players.size != 1
      @turn_user = next_user(user)
    elsif @players.size == 1
      # 最後の一人の場合は、当番なし
      @turn_user = nil
    end

    @players.delete(user)
  end

  # 場からカードをnum枚引く
  def draw_cards(num)
    logger.info "[#{self.class}][#{__method__}]"

    return @cards.slice!(0..num-1)
  end

  # カードを１枚表にする
  def open_card
    logger.info "[#{self.class}][#{__method__}]"

    @upcards << draw_cards(1).first
  end 

  # 引数ユーザの次のユーザを返す
  def next_user(user)
    logger.info "[#{self.class}][#{__method__}]"

    i = @players.index(user)
    return @players[(i+1)%@players.size]
  end

  # 当番ユーザを次の人へまわす
  # ただしフォールドしてる人は飛ばす
  def turn
    logger.info "[#{self.class}][#{__method__}]"

    @turn_user = next_user(@turn_user)
    # turn(@turn_user) if @turn_user.fold_flg
    return @turn_user
  end

  # チップ回収
  def collect_tip
    logger.info "[#{self.class}][#{__method__}]"

    @players.each do |user|
      @tip += user.bet_tip
      user.bet_tip = 0
    end
  end

  # 次のフェーズへ
  def next_phase
    logger.info "[#{self.class}][#{__method__}]"

    @btns_flg = false
    @turn_user = @sb
    @max_user = @sb
    collect_tip()
    case @phase
    # prefloop -> flop
    when PREFLOP
      open_card()
      open_card()
      open_card()
      @phase = FLOP
    # flop -> turn
    when FLOP
      open_card()
      @phase = TURN
    # turn -> river
    when TURN
      open_card()
      @phase = RIVER
    # river -> end
    when RIVER
      collect_tip()
      # 勝敗判定
    else
    end
  end

  def inspect
    return "phase: #{@phase} upcards: #{@upcards} players: #{@players} turn_user: #{@turn_user.inspect} btn: #{@btn} sb: #{@sb} bb: #{@bb}"
  end
end
