class Stream < ApplicationRecord
  self.table_name = 'streams'

  enum :platform, { twitch: 0, you_tube: 1, kick_stream: 2, platform: 3 }, prefix: :platform
  enum :status, { scheduled: 0, live: 1, ended: 2 }, prefix: :status

  belongs_to :tournament, class_name: 'Tournament', optional: true
  belongs_to :streamer, class_name: 'Player'

  validates :title, presence: true, length: { maximum: 300 }
  validates :stream_url, presence: true, length: { maximum: 200 }

  # Domain invariants — simple rules
  validate :validate_rules

  def validate_rules
    errors.add(:viewer_count_not_negative, 'Peak viewer count must not be negative') unless ((viewer_count_peak.nil? || viewer_count_peak >= 0))
  end

  # Domain invariants — IMPLIES rules
  validate :validate_implies

  def validate_implies
    errors.add(:base, 'actual_start_requires_live_or_ended') if (!actual_start.nil?) && !(status == 'live')
    errors.add(:base, 'ended_at can only be set when stream status is Ended') if (!ended_at.nil?) && !(status == 'ended')
  end

  def to_s
    title.to_s
  end

  # Business operations

  def go_live
    raise NotImplementedError, "go_live not implemented"
  end

  def end
    raise NotImplementedError, "end not implemented"
  end

  def update_viewer_peak(count)
    raise NotImplementedError, "update_viewer_peak not implemented"
  end

  def duration_minutes
    raise NotImplementedError, "duration_minutes not implemented"
  end
end
