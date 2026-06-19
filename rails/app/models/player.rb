class Player < ApplicationRecord
  self.table_name = 'players'

  enum :rank, { bronze: 0, silver: 1, gold: 2, platinum: 3, diamond: 4, master: 5, grandmaster: 6 }, prefix: :rank
  enum :preferred_format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :preferred_format

  has_many :decks, class_name: 'Deck', inverse_of: :player
  has_many :season_stats, class_name: 'PlayerSeasonStats', inverse_of: :player
  has_many :collection, class_name: 'PlayerCollection', inverse_of: :player
  has_many :sent_friend_requests, class_name: 'Friendship', inverse_of: :requester
  has_many :received_friend_requests, class_name: 'Friendship', inverse_of: :receiver
  has_many :achievement_records, class_name: 'PlayerAchievement', inverse_of: :player
  has_many :organized_tournaments, class_name: 'Tournament', inverse_of: :organizer
  has_many :judge_roles, class_name: 'TournamentJudge', inverse_of: :player
  has_many :tournament_registrations, class_name: 'TournamentRegistration', inverse_of: :player
  has_many :matches_as_player1, class_name: 'Match', inverse_of: :player1
  has_many :matches_as_player2, class_name: 'Match', inverse_of: :player2
  has_many :won_games, class_name: 'Game', inverse_of: :winner
  has_many :awarded_prizes, class_name: 'AwardedPrize', inverse_of: :player
  has_many :orders, class_name: 'Order', inverse_of: :player
  has_many :trade_listings, class_name: 'TradeListing', inverse_of: :seller
  has_many :bids, class_name: 'TradeBid', inverse_of: :bidder
  has_many :purchases, class_name: 'TradeTransaction', inverse_of: :buyer
  has_many :sales, class_name: 'TradeTransaction', inverse_of: :seller
  has_many :disputes_opened, class_name: 'TradeDispute', inverse_of: :opened_by
  has_many :disputes_resolved, class_name: 'TradeDispute', inverse_of: :resolved_by
  has_many :draft_sessions, class_name: 'DraftParticipant', inverse_of: :player
  has_many :articles, class_name: 'Article', inverse_of: :author
  has_many :article_comments, class_name: 'ArticleComment', inverse_of: :author
  has_many :streams, class_name: 'Stream', inverse_of: :streamer
  belongs_to :user, class_name: 'User', optional: true
  has_many :achievements, class_name: 'Achievement', through: :achievement_records, inverse_of: :players
  has_many :friends, class_name: 'Player', through: :sent_friend_requests, inverse_of: :friends_of

  validates :display_name, presence: true, length: { maximum: 50 }
  validates :display_name, uniqueness: { message: 'display_name must be unique' }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:rating_range, 'Rating must be between 0 and 9999') unless ((rating.nil? || (rating >= 0 && rating <= 9999)))
    errors.add(:peak_rating_gte_rating, 'Peak rating must be greater than or equal to current rating') unless ((peak_rating.nil? || (!rating.nil? && peak_rating >= rating)))
    errors.add(:display_name_not_empty, 'Display name must not be empty') unless (!display_name.nil?)
  end

  def to_s
    display_name.to_s
  end

  # Business operations

  def promote
    # TODO: implement promote
    nil
  end

  def demote
    # TODO: implement demote
    nil
  end

  def record_win
    # TODO: implement record_win
  end

  def record_loss
    # TODO: implement record_loss
  end

  def win_rate
    # TODO: implement win_rate
    nil
  end

  def verify
    # TODO: implement verify
  end

  def update_rating(delta)
    # TODO: implement update_rating
  end

  # Lifecycle hooks
  after_create :initialize_collection
  after_update :update_rank

  def initialize_collection
    # TODO: implement initialize_collection
  end

  def update_rank
    # TODO: implement update_rank
  end

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash['lastActiveAt'] = hash.delete('last_active_at') if hash.key?('last_active_at')
    hash
  end
end
