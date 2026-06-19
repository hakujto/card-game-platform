class ArticleTagAssignment < ApplicationRecord
  self.table_name = 'article_tag_assignments'

  belongs_to :article, class_name: 'Article', inverse_of: :tag_assignments
  belongs_to :tag, class_name: 'ArticleTag', inverse_of: :article_assignments

  def to_s
    id.to_s
  end
end
