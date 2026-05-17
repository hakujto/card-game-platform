class DeckTag < ApplicationRecord
  self.table_name = 'deck_tags'

  validates :name, presence: true, length: { maximum: 50 }

  def to_s
    name.to_s
  end

  # Business operations

  def rename(new_name)
    raise NotImplementedError, "rename not implemented"
  end

  def merge_into(target_tag_id)
    raise NotImplementedError, "merge_into not implemented"
  end
end
