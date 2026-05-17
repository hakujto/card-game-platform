class CreateArticleComments < ActiveRecord::Migration[7.1]
  def change
    create_table :article_comments do |t|
      t.text :body, null: false
      t.boolean :is_hidden, null: false, default: false
      t.references :article, null: false, foreign_key: { to_table: :articles }
      t.references :author, null: false, foreign_key: { to_table: :players }
      t.references :parent_comment, null: true, foreign_key: { to_table: :article_comments }

      t.timestamps
    end
  end
end
