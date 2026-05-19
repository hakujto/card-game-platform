class Friendship < ApplicationRecord
  self.table_name = 'friendships'

  enum :status, { pending: 0, accepted: 1, blocked: 2 }

  belongs_to :requester, class_name: 'Player'
  belongs_to :receiver, class_name: 'Player'

  def to_s
    status.to_s
  end

  # Business operations

  def accept
    # TODO: implement accept
  end

  def decline
    # TODO: implement decline
  end

  def block
    # TODO: implement block
  end
end
