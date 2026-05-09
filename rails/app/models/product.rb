class Product < ApplicationRecord
  self.table_name = 'products'

  enum :product_type, { single_card: 0, booster_pack: 1, bundle: 2, preconstructed_deck: 3, accessory: 4 }

  belongs_to :card, class_name: 'Card', optional: true
  belongs_to :card_set, class_name: 'CardSet', optional: true

  validates :name, presence: true, length: { maximum: 200 }

  def to_s
    name.to_s
  end
end
