class Achievement < ApplicationRecord
  self.table_name = 'achievements'

  enum :rarity, { common: 0, uncommon: 1, rare: 2, epic: 3, legendary: 4 }

  validates :name, presence: true, length: { maximum: 200 }

  def to_s
    name.to_s
  end
end
