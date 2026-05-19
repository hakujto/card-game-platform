class CardRuling < ApplicationRecord
  self.table_name = 'card_rulings'

  belongs_to :card, class_name: 'Card'

  validates :source, presence: true, length: { maximum: 200 }

  def to_s
    ruling_text.to_s
  end

  # Business operations

  def is_current
    # TODO: implement is_current
    nil
  end

  def supersedes_previous
    # TODO: implement supersedes_previous
    nil
  end
end
