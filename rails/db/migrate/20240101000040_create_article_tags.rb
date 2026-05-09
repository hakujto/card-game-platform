class CreateArticleTags < ActiveRecord::Migration[7.1]
  def change
    create_table :article_tags do |t|
      t.string :name, limit: 100, null: false
      t.string :slug, limit: 100, null: false

      t.timestamps
    end
  end
end
