class Season < ApplicationRecord
  self.table_name = 'seasons'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }

  has_many :player_stats, class_name: 'PlayerSeasonStats', inverse_of: :season
  has_many :tournaments, class_name: 'Tournament', inverse_of: :season

  validates :name, presence: true, length: { maximum: 200 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:end_date_after_start_date, 'Season end date must be after start date') unless ((end_date.nil? || (!start_date.nil? && end_date > start_date)))
  end

  def to_s
    name.to_s
  end

  # Business operations

  def activate
    # TODO: implement activate
  end

  def deactivate
    # TODO: implement deactivate
  end

  def finalize_rewards
    # TODO: implement finalize_rewards
  end

  def is_ongoing
    # TODO: implement is_ongoing
    nil
  end
end
