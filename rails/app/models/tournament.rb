class Tournament < ApplicationRecord
  self.table_name = 'tournaments'

  enum :status, { draft: 0, registration: 1, ongoing: 2, completed: 3, cancelled: 4 }, prefix: :status
  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }, prefix: :format
  enum :tournament_type, { swiss: 0, single_elimination: 1, double_elimination: 2, round_robin: 3 }, prefix: :tournament_type

  has_many :judge_assignments, class_name: 'TournamentJudge', inverse_of: :tournament
  has_many :registrations, class_name: 'TournamentRegistration', inverse_of: :tournament
  has_many :rounds, class_name: 'TournamentRound', inverse_of: :tournament
  has_many :prizes, class_name: 'TournamentPrize', inverse_of: :tournament
  has_many :streams, class_name: 'Stream', inverse_of: :tournament
  belongs_to :season, class_name: 'Season', inverse_of: :tournaments
  belongs_to :organizer, class_name: 'Player', inverse_of: :organized_tournaments
  has_many :judges, class_name: 'Player', through: :judge_assignments, inverse_of: :judged_tournaments

  attr_readonly :created_at

  validates :name, presence: true, length: { maximum: 200 }
  validates :max_players, numericality: { greater_than_or_equal_to: 2, less_than_or_equal_to: 512 }
  validates :public_id, uniqueness: { message: 'public_id must be unique' }

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
    public_id.to_s
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
  before_destroy :prevent_delete_if_ongoing

  def sync_season_stats
    # TODO: implement sync_season_stats
  end

  def prevent_delete_if_ongoing
    # TODO: implement prevent_delete_if_ongoing
  end

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash['startTime'] = hash.delete('start_time') if hash.key?('start_time')
    hash['endTime'] = hash.delete('end_time') if hash.key?('end_time')
    hash
  end

  before_update :_audit_changes

  def _audit_changes
    [].each do |field|
      if changes.key?(field.to_s)
        TournamentAuditLog.create!(
          record: self, field: field.to_s,
          old_value: changes[field.to_s][0].to_s,
          new_value: changes[field.to_s][1].to_s
        )
      end
    end
  end
end

class TournamentAuditLog < ApplicationRecord
  self.table_name = 'tournaments_audit_logs'
  belongs_to :record, class_name: 'Tournament'
end
