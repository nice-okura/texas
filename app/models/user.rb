# -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :user_id, :name, :hand, :bet_tip, :keep_tip, :fold

  # チップを賭ける
  def bet(tip)
    self.bet_tip = tip
    self.keep_tip -= tip
  end
end
