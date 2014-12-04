# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :user_id, :name, :hand, :bet_tip, :keep_tip, :fold

  # チップを賭ける
  def bet(tip)
    self.bet_tip = tip
    self.keep_tip -= tip
  end

  def call()
    gap = Texas::Application.config.table.maxtip - self.bet_tip
    if self.keep_tip < gap
      flash.now[:alert] = 'チップが足りません'
    else
      self.bet_tip += gap
      self.keep_tip -= gap
    end
  end

  def fold()
  end

  def check()
  end

  def bet(tip)
  end

  def raise(tip)
  end

end
