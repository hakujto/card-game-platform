class DraftPick < ApplicationRecord
  self.table_name = 'draft_picks'

  belongs_to :participant, class_name: 'DraftParticipant'
  belongs_to :card, class_name: 'Card'

  def to_s
    pick_number.to_s
  end
end
