class CreateArticleTags < ActiveRecord::Migration[7.1]
  def change
    create_table :article_tags do |t|
      t.string :name, limit: 100, null: false
      t.string :slug, limit: 100, null: false

      t.timestamps
    end
    add_index :article_tags, :slug, unique: true
  end
end
