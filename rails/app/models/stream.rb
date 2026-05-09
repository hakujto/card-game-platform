class Stream < ApplicationRecord
  self.table_name = 'streams'

  enum :platform, { twitch: 0, you_tube: 1, kick_stream: 2, platform: 3 }, prefix: :platform
  enum :status, { scheduled: 0, live: 1, ended: 2 }, prefix: :status

  belongs_to :tournament, class_name: 'Tournament', optional: true
  belongs_to :streamer, class_name: 'Player'

  validates :title, presence: true, length: { maximum: 300 }
  validates :stream_url, presence: true, length: { maximum: 200 }

  def to_s
    title.to_s
  end
end
