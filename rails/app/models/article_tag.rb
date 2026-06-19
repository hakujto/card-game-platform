class ArticleTag < ApplicationRecord
  self.table_name = 'article_tags'

  has_many :article_assignments, class_name: 'ArticleTagAssignment', inverse_of: :tag

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, length: { maximum: 100 }
  validates :slug, uniqueness: { message: 'slug must be unique' }

  def to_s
    name.to_s
  end

  # Business operations

  def rename(new_name)
    # TODO: implement rename
  end

  def article_count
    # TODO: implement article_count
    nil
  end
end
