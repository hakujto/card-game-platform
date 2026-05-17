class DraftPick < ApplicationRecord
  self.table_name = 'draft_picks'

  belongs_to :participant, class_name: 'DraftParticipant'
  belongs_to :card, class_name: 'Card'

  def to_s
    pick_number.to_s
  end

  # Business operations

  def is_first_pick
    raise NotImplementedError, "is_first_pick not implemented"
  end
end
