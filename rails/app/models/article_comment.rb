class ArticleComment < ApplicationRecord
  self.table_name = 'article_comments'

  has_many :replies, class_name: 'ArticleComment', inverse_of: :parent_comment
  belongs_to :article, class_name: 'Article', inverse_of: :comments
  belongs_to :author, class_name: 'Player', inverse_of: :article_comments
  belongs_to :parent_comment, class_name: 'ArticleComment', inverse_of: :replies, optional: true

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

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash
  end
end
