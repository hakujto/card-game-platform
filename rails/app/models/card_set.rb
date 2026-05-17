class CardSet < ApplicationRecord
  self.table_name = 'card_sets'

  enum :set_type, { core: 0, expansion: 1, supplemental: 2, masters: 3, draft: 4 }

  validates :name, presence: true, length: { maximum: 200 }
  validates :code, presence: true, length: { maximum: 10 }

  def to_s
    name.to_s
  end

  # Business operations

  def is_legal_in_standard
    raise NotImplementedError, "is_legal_in_standard not implemented"
  end
end
