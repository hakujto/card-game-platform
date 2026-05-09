class ArticleTag < ApplicationRecord
  self.table_name = 'article_tags'

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, length: { maximum: 100 }

  def to_s
    name.to_s
  end
end
