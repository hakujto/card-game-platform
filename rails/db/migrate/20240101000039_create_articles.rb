class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title, limit: 300, null: false
      t.string :slug, limit: 300, null: false
      t.text :body, null: false
      t.text :excerpt, null: true
      t.string :cover_image_url, limit: 200, null: true
      t.integer :status, null: false, default: 0 # enum: { draft: 0, published: 1, archived: 2 }
      t.integer :article_type, null: false, default: 0 # enum: { guide: 0, tierlist: 1, matchup: 2, news: 3, spotlight: 4, decklist: 5 }
      t.integer :view_count, null: false, default: 0
      t.datetime :published_at, null: true
      t.references :author, null: false, foreign_key: { to_table: :players }
      t.references :featured_deck, null: true, foreign_key: { to_table: :decks }
      t.references :comments, null: false, foreign_key: { to_table: :article_comments }

      t.timestamps
    end
  end
end
