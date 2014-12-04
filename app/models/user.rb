class User < ActiveRecord::Base
  attr_accessible :user_id, :name, :hand, :bet_tip, :keep_tip, :fold
end
