class ArticleTagAssignment < ApplicationRecord
  self.table_name = 'article_tag_assignments'

  belongs_to :article, class_name: 'Article'
  belongs_to :tag, class_name: 'ArticleTag'

  def to_s
    id.to_s
  end
end
