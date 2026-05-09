class CreateDeckTags < ActiveRecord::Migration[7.1]
  def change
    create_table :deck_tags do |t|
      t.string :name, limit: 50, null: false
      t.string :color, limit: 7, null: true

      t.timestamps
    end
  end
end
