class Article < ApplicationRecord
  self.table_name = 'articles'

  enum :status, { draft: 0, published: 1, archived: 2 }, prefix: :status
  enum :article_type, { guide: 0, tierlist: 1, matchup: 2, news: 3, spotlight: 4, decklist: 5 }, prefix: :article_type

  belongs_to :author, class_name: 'Player'
  belongs_to :featured_deck, class_name: 'Deck', optional: true
  has_many :tags, class_name: 'ArticleTag', through: :article_tag_assignments

  validates :title, presence: true, length: { maximum: 300 }
  validates :slug, presence: true, length: { maximum: 300 }

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'Published article must have a published_at timestamp') if (status == 'published') && published_at.nil?
  end

  def to_s
    title.to_s
  end

  # Business operations

  def publish
    raise NotImplementedError, "publish not implemented"
  end

  def archive
    raise NotImplementedError, "archive not implemented"
  end

  def increment_view
    raise NotImplementedError, "increment_view not implemented"
  end

  def reading_time_minutes
    raise NotImplementedError, "reading_time_minutes not implemented"
  end
end
