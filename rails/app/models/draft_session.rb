class DraftSession < ApplicationRecord
  self.table_name = 'draft_sessions'

  enum :status, { waiting_for_players: 0, drafting: 1, completed: 2, abandoned: 3 }, prefix: :status
  enum :draft_type, { booster: 0, cube: 1, rochester: 2 }, prefix: :draft_type

  belongs_to :card_set, class_name: 'CardSet'
  belongs_to :participants, class_name: 'DraftParticipant'

  def to_s
    status.to_s
  end
end
