class CreateFriendships < ActiveRecord::Migration[7.1]
  def change
    create_table :friendships do |t|
      t.integer :status, null: false, default: 0 # enum: { pending: 0, accepted: 1, blocked: 2 }
      t.references :requester, null: false, foreign_key: { to_table: :players }
      t.references :receiver, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
