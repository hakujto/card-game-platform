class CreateArticleTagAssignments < ActiveRecord::Migration[7.1]
  def change
    create_table :article_tag_assignments do |t|
      t.references :article, null: false, foreign_key: { to_table: :articles }
      t.references :tag, null: false, foreign_key: { to_table: :article_tags }

      t.timestamps
    end
  end
end
