class Tournament < ApplicationRecord
  self.table_name = 'tournaments'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :format
  enum :tournament_type, { swiss: 0, single_elimination: 1, double_elimination: 2, round_robin: 3 }, prefix: :tournament_type
  enum :status, { draft: 0, registration: 1, ongoing: 2, completed: 3, cancelled: 4 }, prefix: :status

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
    raise NotImplementedError, "start not implemented"
  end

  def cancel
    raise NotImplementedError, "cancel not implemented"
  end

  def complete
    raise NotImplementedError, "complete not implemented"
  end

  def generate_round
    raise NotImplementedError, "generate_round not implemented"
  end

  def calculate_prize_distribution
    raise NotImplementedError, "calculate_prize_distribution not implemented"
  end

  def register_player(player_id, deck_id)
    raise NotImplementedError, "register_player not implemented"
  end

  def is_full
    raise NotImplementedError, "is_full not implemented"
  end
end
