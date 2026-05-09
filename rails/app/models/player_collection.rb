class PlayerCollection < ApplicationRecord
  self.table_name = 'player_collections'

  enum :condition, { mint: 0, near_mint: 1, excellent: 2, good: 3, played: 4 }, prefix: :condition
  enum :acquired_via, { purchase: 0, trade: 1, tournament_reward: 2, pack: 3, craft: 4 }, prefix: :acquired_via

  belongs_to :player, class_name: 'Player'
  belongs_to :card, class_name: 'Card'

  def to_s
    quantity.to_s
  end
end
