class CreateAchievements < ActiveRecord::Migration[7.1]
  def change
    create_table :achievements do |t|
      t.string :name, limit: 200, null: false
      t.text :description, null: false
      t.string :icon_url, limit: 200, null: true
      t.integer :points, null: false, default: 10
      t.integer :rarity, null: false, default: 0 # enum: { common: 0, uncommon: 1, rare: 2, epic: 3, legendary: 4 }
      t.boolean :is_hidden, null: false, default: false

      t.timestamps
    end
  end
end
