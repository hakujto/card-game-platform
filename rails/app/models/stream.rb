class Stream < ApplicationRecord
  self.table_name = 'streams'

  enum :status, { scheduled: 0, live: 1, ended: 2 }, prefix: :status
  enum :platform, { twitch: 0, you_tube: 1, kick_stream: 2, platform: 3 }, prefix: :platform
  enum :language, { e_n: 0, d_e: 1, f_r: 2, i_t: 3, e_s: 4, j_p: 5, p_t: 6 }, prefix: :language

  belongs_to :tournament, class_name: 'Tournament', inverse_of: :streams, optional: true
  belongs_to :streamer, class_name: 'Player', inverse_of: :streams

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
    # TODO: implement go_live
  end

  def end
    # TODO: implement end
  end

  def update_viewer_peak(count)
    # TODO: implement update_viewer_peak
  end

  def duration_minutes
    # TODO: implement duration_minutes
    nil
  end

  # Lifecycle state machine
  ALLOWED_TRANSITIONS = {
    'scheduled' => ['live'],
    'live' => ['ended'],
  }.freeze

  def assert_transition!(to_state)
    allowed = ALLOWED_TRANSITIONS.fetch(status.to_s, [])
    unless allowed.include?(to_state.to_s)
      raise ArgumentError, "Transition #{status} -> #{to_state} not allowed"
    end
  end

  def as_json(options = {})
    hash = super(options)
    hash['scheduledStart'] = hash.delete('scheduled_start') if hash.key?('scheduled_start')
    hash['actualStart'] = hash.delete('actual_start') if hash.key?('actual_start')
    hash['endedAt'] = hash.delete('ended_at') if hash.key?('ended_at')
    hash
  end
end
