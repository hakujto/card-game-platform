class CreateArticleComments < ActiveRecord::Migration[7.1]
  def change
    create_table :article_comments do |t|
      t.text :body, null: false
      t.boolean :is_hidden, null: false, default: false
      t.references :article, null: false, foreign_key: { to_table: :articles, on_delete: :cascade }
      t.references :author, null: false, foreign_key: { to_table: :players, on_delete: :restrict }
      t.references :parent_comment, null: true, foreign_key: { to_table: :article_comments, on_delete: :nullify }

      t.timestamps
    end
  end
end
