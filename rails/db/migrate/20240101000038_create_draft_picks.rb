class CreateDraftPicks < ActiveRecord::Migration[7.1]
  def change
    create_table :draft_picks do |t|
      t.integer :pick_number, null: false
      t.integer :pack_number, null: false
      t.datetime :picked_at, null: false
      t.references :participant, null: false, foreign_key: { to_table: :draft_participants }
      t.references :card, null: false, foreign_key: { to_table: :cards }

      t.timestamps
    end
  end
end
