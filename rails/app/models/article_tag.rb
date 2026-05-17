class ArticleTag < ApplicationRecord
  self.table_name = 'article_tags'

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, length: { maximum: 100 }

  def to_s
    name.to_s
  end

  # Business operations

  def rename(new_name)
    raise NotImplementedError, "rename not implemented"
  end

  def article_count
    raise NotImplementedError, "article_count not implemented"
  end
end
