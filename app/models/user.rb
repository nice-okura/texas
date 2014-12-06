# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :user_id, :name, :hand, :bet_tip, :keep_tip, :fold

  # チップを賭ける
  def gamble(tip)
    self.bet_tip += tip
    self.keep_tip -= tip
  end

  # call
  def call
    logger.debug "User.call()が呼ばれた"
    max_tip = Texas::Application.config.table.max_user.bet_tip
    gap = max_tip - self.bet_tip
    self.gamble(gap)
  end

  # fold
  def fold
    logger.debug "User.fold()が呼ばれた"
    self.fold = true
  end

  # check
  def check
    logger.debug "User.check()が呼ばれた"
  end

  # bet
  # @param [int] tip ベットする金額
  def bet(tip)
    logger.debug "User.bet()が呼ばれた"
  end

  # raise
  # @param [int] tip レイズする金額
  def raise(tip)
    logger.debug "User.raise()が呼ばれた"
    self.gamble(tip)
    Texas::Application.config.table.max_user = self
  end

end
