class Friendship < ApplicationRecord
  self.table_name = 'friendships'

  enum :status, { pending: 0, accepted: 1, blocked: 2 }

  belongs_to :requester, class_name: 'Player', inverse_of: :sent_friend_requests
  belongs_to :receiver, class_name: 'Player', inverse_of: :received_friend_requests

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

  def as_json(options = {})
    hash = super(options)
    hash['createdAt'] = hash.delete('created_at') if hash.key?('created_at')
    hash
  end
end
