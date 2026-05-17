class ArticleComment < ApplicationRecord
  self.table_name = 'article_comments'

  belongs_to :article, class_name: 'Article'
  belongs_to :author, class_name: 'Player'
  belongs_to :parent_comment, class_name: 'ArticleComment', optional: true

  def to_s
    body.to_s
  end

  # Business operations

  def hide
    raise NotImplementedError, "hide not implemented"
  end

  def unhide
    raise NotImplementedError, "unhide not implemented"
  end

  def is_reply
    raise NotImplementedError, "is_reply not implemented"
  end
end
