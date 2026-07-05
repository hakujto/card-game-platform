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
      t.integer :language, null: false, default: 0 # enum: { e_n: 0, d_e: 1, f_r: 2, i_t: 3, e_s: 4, j_p: 5, p_t: 6 }
      t.integer :view_count, null: false, default: 0
      t.integer :likes_count, null: false, default: 0
      t.bigint :total_views_alltime, null: false, default: 0
      t.boolean :is_featured, null: false, default: false
      t.datetime :published_at, null: true
      t.references :author, null: false, foreign_key: { to_table: :players, on_delete: :restrict }
      t.references :featured_deck, null: true, foreign_key: { to_table: :decks, on_delete: :nullify }

      t.timestamps
    end
    add_index :articles, :slug, unique: true
  end
end
