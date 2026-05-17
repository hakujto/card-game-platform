class CreateDraftParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :draft_participants do |t|
      t.integer :seat_number, null: false
      t.datetime :joined_at, null: false
      t.references :session, null: false, foreign_key: { to_table: :draft_sessions }
      t.references :player, null: false, foreign_key: { to_table: :players }

      t.timestamps
    end
  end
end
