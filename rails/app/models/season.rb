class Season < ApplicationRecord
  self.table_name = 'seasons'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }

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
    raise NotImplementedError, "activate not implemented"
  end

  def deactivate
    raise NotImplementedError, "deactivate not implemented"
  end

  def finalize_rewards
    raise NotImplementedError, "finalize_rewards not implemented"
  end

  def is_ongoing
    raise NotImplementedError, "is_ongoing not implemented"
  end
end
