class CreateSeasons < ActiveRecord::Migration[7.1]
  def change
    create_table :seasons do |t|
      t.string :name, limit: 200, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :format, null: false, default: 0 # enum: { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }
      t.boolean :is_active, null: false, default: false
      t.text :reward_description, null: true

      t.timestamps
    end
  end
end
