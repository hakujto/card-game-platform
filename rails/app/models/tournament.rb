class Tournament < ApplicationRecord
  self.table_name = 'tournaments'

  enum :status, { draft: 0, registration: 1, ongoing: 2, completed: 3, cancelled: 4 }, prefix: :status
  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :format
  enum :tournament_type, { swiss: 0, single_elimination: 1, double_elimination: 2, round_robin: 3 }, prefix: :tournament_type

  belongs_to :season, class_name: 'Season'
  belongs_to :organizer, class_name: 'Player'
  has_many :judges, class_name: 'Player', through: :tournament_judges

  validates :name, presence: true, length: { maximum: 200 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:max_players_positive, 'Tournament must allow between 2 and 512 players') unless ((max_players.nil? || (max_players >= 2 && max_players <= 512)))
    errors.add(:entry_fee_not_negative, 'Entry fee must not be negative') unless ((entry_fee.nil? || entry_fee.to_f >= 0))
    errors.add(:prize_pool_not_negative, 'Prize pool must not be negative') unless ((prize_pool.nil? || prize_pool.to_f >= 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'End time must be after start time') if (!end_time.nil?) && !((end_time.nil? || (!start_time.nil? && end_time > start_time)))
  end

  def to_s
    name.to_s
  end

  # Business operations

  def start
    # TODO: implement start
  end

  def cancel
    # TODO: implement cancel
  end

  def complete
    # TODO: implement complete
  end

  def generate_round
    # TODO: implement generate_round
  end

  def calculate_prize_distribution
    # TODO: implement calculate_prize_distribution
    nil
  end

  def register_player(player_id, deck_id)
    # TODO: implement register_player
  end

  def is_full
    # TODO: implement is_full
    nil
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'draft' => ['registration'],
    'registration' => ['ongoing', 'cancelled'],
    'ongoing' => ['completed', 'cancelled'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end

  # Lifecycle hooks
  after_update :sync_season_stats

  def sync_season_stats
    # TODO: implement sync_season_stats
  end

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash['startTime'] = hash.delete('start_time') if hash.key?('start_time')
    hash['endTime'] = hash.delete('end_time') if hash.key?('end_time')
    hash
  end
end
