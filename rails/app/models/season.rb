class Season < ApplicationRecord
  self.table_name = 'seasons'

  enum :format, { standard: 0, extended: 1, legacy: 2, vintage: 3, commander: 4, draft: 5 }

  validates :name, presence: true, length: { maximum: 200 }

  def to_s
    name.to_s
  end
end
