class CardPriceHistory < ApplicationRecord
  self.table_name = 'card_price_histories'

  belongs_to :card, class_name: 'Card'

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:price_bounds_consistent, 'min_price <= avg_price <= max_price must hold') unless (((min_price.nil? || (!avg_price.nil? && min_price.to_f <= avg_price.to_f)) && (avg_price.nil? || (!max_price.nil? && avg_price.to_f <= max_price.to_f))))
  end

  def to_s
    price_date.to_s
  end

  # Business operations

  def price_change_percent(previous_avg)
    raise NotImplementedError, "price_change_percent not implemented"
  end

  def is_price_spike(threshold_percent)
    raise NotImplementedError, "is_price_spike not implemented"
  end
end
