class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :id => false, :primary_key => :user_id do |t|
      t.integer :user_id
      t.string :name
      t.integer :keep_tip
      t.string :hand
      t.integer :bet_tip
      t.boolean :fold_flg
      t.timestamps
    end
  end
end
