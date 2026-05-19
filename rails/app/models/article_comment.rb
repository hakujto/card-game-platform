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
    # TODO: implement hide
  end

  def unhide
    # TODO: implement unhide
  end

  def is_reply
    # TODO: implement is_reply
    nil
  end
end
