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
  attribute :winners
  attr_accessor :upcards, :cards, :phase, :tip, :turn_user, :players, :btn, :sb, :bb, :max_user, :btns_flg, :winners

  MAX_OPEN_CARD = 5
  PREFLOP = "preflop" # 0枚オープン
  FLOP = "flop"       # 3枚オープン
  TURN = "turn"       # 4枚オープン
  RIVER = "river"     # 5枚オープン
  FINISH = "finish"   # おわり
  
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
  # ただし第二引数fold_flg_checkがfalseでなければフォールドしてる人は飛ばす
  def next_user(user, fold_flg_check = true)
    logger.info "[#{self.class}][#{__method__}]"

    i = @players.index(user)
    next_turn_user = @players[(i + 1) % @players.size]
    if fold_flg_check && next_turn_user.fold_flg
      next_turn_user = next_user(next_turn_user)
    else
      return next_turn_user
    end
  end

  # 当番ユーザを次の人へまわす
  def turn
    logger.info "[#{self.class}][#{__method__}]"

    @turn_user = next_user(@turn_user)
    logger.debug("@turn_user: #{@turn_user.inspect}")
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
    if @sb.fold_flg
      @turn_user = next_user(@sb)
      @max_user = next_user(@sb)
    else
      @turn_user = @sb
      @max_user = @sb
    end

    collect_tip()

    case @phase
    # 今preflopの場合flopへ移行する
    when PREFLOP
      logger.info "preflop -> flop"

      open_card()
      open_card()
      open_card()

      @phase = FLOP
    # 今flopの場合turnへ移行する
    when FLOP
      logger.info "flop -> turn"

      open_card()

      @phase = TURN
      # 今turnの場合riverへ移行する
    when TURN
      logger.info "turn -> river"

      open_card()
      ###################################################################
      # 手札とテーブル上のカードを設定（テスト用）
      # @upcards = ["02s", "02c", "03s", "03c", "04h"]
      # @players[0].hand = ["01s", "01h"]
      # @players[1].hand = ["13c", "13s"]
      ###################################################################

      @phase = RIVER
    # 今riverの場合endへ移行する
    when RIVER
      logger.info "river -> finish"

      @phase = FINISH

      @winners = judge()
      @winners.each do |winner|
        winner.keep_tip += @tip / @winners.size
      end

      @tip = 0
    else
    end
  end

  # 勝敗判定
  def judge
    logger.info "[#{self.class}][#{__method__}]"

    winners = [] # 戻り値
    data = []

    # 役判定
    points = []
    players_final = @players.select { |p| !p.fold_flg }
    
    players_final.each do |user|
      logger.debug user.name

      max_point = 0   # 一人のプレイヤーの役の最大ポイント
      points_tmp = []
      nums_tmp = []
      max_hands = []
      max_numss = []

      (user.hand + @upcards).combination(5) do |h|
        point = 0
        
        # プレイヤーの数字とマーク
        nums = h.collect { |c| c[0..1].to_i }.sort
        suits = h.collect { |c| c[2] }

        straight_flg = (nums == (nums[0]..nums[0]+4).to_a || nums == [1,10,11,12,13])
        flush_flg = suits.uniq.size == 1

        if straight_flg && flush_flg 
          point = 8 # straight flush
        elsif flush_flg
          point = 5 # flush
        elsif straight_flg
          point = 4 # straight
        else
          groups = nums.uniq.collect { |n| nums.count(n) }.sort
          
          case groups
          when [1, 4] then point = 7       # four of a kind
          when [2, 3] then point = 6       # full house
          when [1, 1, 3] then point = 3    # three of a kind
          when [1, 2, 2] then point = 2    # two pair
          when [1, 1, 1, 2] then point = 1 # one pair
          end
        end

        # 最強の役になる組み合わせをすべて保持
        if point == max_point
          max_hands << h
          max_numss << nums
        elsif point > max_point
          max_hands = [h]
          max_numss = [nums]
          max_point = point
        end

        logger.debug "#{h.inspect} -> #{point}"
      end
      
      logger.debug "max_numss = #{max_numss.uniq.inspect}"

      data << {user: user, hands: max_hands.uniq, numss: max_numss.uniq, point: max_point}
      points << max_point
    end

    logger.debug points.inspect

    data.select! { |d| d[:point] == points.max }

    # 役だけで勝者が決定する場合
    if data.size == 1
      logger.debug "役だけで決まった"
      winners = data.collect { |d| d[:user] }
    # 役だけでは勝者が決定しない場合
    elsif data.size > 1
      logger.debug "役だけでは決まらなかった"

      max_values = []

      # 各ユーザの最強手札を決める
      data.each do |d|
        # 各手札の評価値を求める
        # 評価値とは手札を重複数・数値の大きい順に並べ替えて数値化したもの
        values = []

        d[:numss].each do |nums|
          value_arrays = []

          # 1を14に変換
          unless nums == [1, 2, 3, 4, 5]
            nums.collect! do |n|
              n == 1 ? 14 : n
            end
            nums.sort!
          end

          # 重複数・数値の大きい順に並べ替え
          5.downto(1) do |rep|
            value_arrays << nums.select { |n| nums.count(n) == rep }.reverse
          end

          value_array = value_arrays.flatten.collect { |n| sprintf("%02d", n) }

          # 評価値
          values << value_array.join.to_i
        end

        logger.debug "#{d[:user].name}の各手札の評価値：#{values}"

        max_values << values.max
      end

      logger.debug "各ユーザの評価値：#{max_values}"

      data.each_index do |i|
        winners << data[i][:user] if max_values[i] == max_values.max
      end
    end

    return winners
  end

  def inspect
    return "phase: #{@phase} upcards: #{@upcards} players: #{@players} turn_user: #{@turn_user.inspect} btn: #{@btn} sb: #{@sb} bb: #{@bb}"
  end
end
