class CardRuling < ApplicationRecord
  self.table_name = 'card_rulings'

  belongs_to :card, class_name: 'Card'

  validates :source, presence: true, length: { maximum: 200 }

  def to_s
    ruling_text.to_s
  end

  # Business operations

  def is_current
    raise NotImplementedError, "is_current not implemented"
  end

  def supersedes_previous
    raise NotImplementedError, "supersedes_previous not implemented"
  end
end
