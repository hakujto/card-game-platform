class CreateDraftParticipants < ActiveRecord::Migration[7.1]
  def change
    create_table :draft_participants do |t|
      t.integer :seat_number, null: false
      t.datetime :joined_at, null: false
      t.references :session, null: true, foreign_key: { to_table: :draft_sessions }
      t.references :player, null: false, foreign_key: { to_table: :players }
      t.references :drafted_cards, null: true, foreign_key: { to_table: :draft_picks }

      t.timestamps
    end
  end
end
