class DeckTag < ApplicationRecord
  self.table_name = 'deck_tags'

  has_many :deck_assignments, class_name: 'DeckTagAssignment', inverse_of: :tag

  validates :name, presence: true, length: { maximum: 50 }

  def to_s
    name.to_s
  end

  # Business operations

  def rename(new_name)
    # TODO: implement rename
  end

  def merge_into(target_tag_id)
    # TODO: implement merge_into
  end
end
