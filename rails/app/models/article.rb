class Article < ApplicationRecord
  self.table_name = 'articles'

  enum :status, { draft: 0, published: 1, archived: 2 }, prefix: :status
  enum :article_type, { guide: 0, tierlist: 1, matchup: 2, news: 3, spotlight: 4, decklist: 5 }, prefix: :article_type
  enum :language, { e_n: 0, d_e: 1, f_r: 2, i_t: 3, e_s: 4, j_p: 5, p_t: 6 }, prefix: :language

  belongs_to :author, class_name: 'Player'
  belongs_to :featured_deck, class_name: 'Deck', optional: true
  has_many :tags, class_name: 'ArticleTag', through: :article_tag_assignments

  validates :title, presence: true, length: { maximum: 300 }
  validates :slug, presence: true, length: { maximum: 300 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:view_count_not_negative, 'Article view count must not be negative') unless ((view_count.nil? || view_count >= 0))
    errors.add(:likes_count_not_negative, 'Article likes count must not be negative') unless ((likes_count.nil? || likes_count >= 0))
  end

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
    # TODO: implement publish
  end

  def archive
    # TODO: implement archive
  end

  def increment_view
    # TODO: implement increment_view
  end

  def like
    # TODO: implement like
  end

  def unlike
    # TODO: implement unlike
  end

  def reading_time_minutes
    # TODO: implement reading_time_minutes
    nil
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'draft' => ['published'],
    'published' => ['archived'],
    'archived' => ['draft'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end
end
