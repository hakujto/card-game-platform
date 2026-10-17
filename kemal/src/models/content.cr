require "db"
require "json"

class DraftSession
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property status : String = "WaitingForPlayers"
  property draft_type : String = "Booster"
  property pack_contents : String?
  property seats : Int32 = 8
  property time_per_pick_seconds : Int32 = 30
  property completed_at : String?
  property card_set_id : Int64?

  def start()
    # TODO: implement start
  end

  def abandon()
    # TODO: implement abandon
  end

  def complete()
    # TODO: implement complete
  end

  def is_full() : Bool
    # TODO: implement is_full
    false
  end

  enum DraftSessionStatus
    WaitingForPlayers
    Drafting
    Completed
    Abandoned
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Completed", "Abandoned"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: Draft session must have between 2 and 16 seats
    errors << "Draft session must have between 2 and 16 seats" if !((seats >= 2 && seats <= 16))
    # Rule: completed_at can only be set when draft status is Completed
    errors << "completed_at can only be set when draft status is Completed" if !(!(completed_at != nil) || (status == Completed))
    # Rule: Time per pick must be greater than zero
    errors << "Time per pick must be greater than zero" if !(time_per_pick_seconds > 0)
    errors
  end

end

class DraftParticipant
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property seat_number : Int32
  property joined_at : String
  property session_id : Int64?
  property player_id : Int64?

  def pick_card(card_id : Int32, pack_number : Int32)
    # TODO: implement pick_card
  end

  def drafted_card_count() : Int32
    # TODO: implement drafted_card_count
    0
  end

  def validate
    errors = [] of String
    # Rule: Seat number must be greater than zero
    errors << "Seat number must be greater than zero" if !(seat_number > 0)
    errors
  end

end

class DraftPick
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property pick_number : Int32
  property pack_number : Int32
  property picked_at : String
  property participant_id : Int64?
  property card_id : Int64?

  def is_first_pick() : Bool
    # TODO: implement is_first_pick
    false
  end

  def validate
    errors = [] of String
    # Rule: Pick number must be greater than zero
    errors << "Pick number must be greater than zero" if !(pick_number > 0)
    # Rule: Pack number must be between 1 and 3
    errors << "Pack number must be between 1 and 3" if !((pack_number >= 1 && pack_number <= 3))
    errors
  end

end

class Article
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property title : String
  property slug : String
  property body : String
  property excerpt : String?
  property cover_image_url : String?
  property status : String = "Draft"
  property article_type : String = "Guide"
  property language : String = "EN"
  property view_count : Int32 = 0
  property likes_count : Int32 = 0
  property total_views_alltime : Int64 = 0
  property is_featured : Bool = false
  property published_at : String?
  property author_id : Int64?
  property featured_deck_id : Int64?

  def publish()
    # TODO: implement publish
  end

  def archive()
    # TODO: implement archive
  end

  def replace(data : String) : Bool
    # TODO: implement replace
    false
  end

  def increment_view()
    # TODO: implement increment_view
  end

  def like()
    # TODO: implement like
  end

  def unlike()
    # TODO: implement unlike
  end

  def reading_time_minutes() : Int32
    # TODO: implement reading_time_minutes
    0
  end

  enum ArticleStatus
    Draft
    Published
    Archived
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Published"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: Published article must have a published_at timestamp
    errors << "Published article must have a published_at timestamp" if !(!(status == Published) || (published_at != nil))
    # Rule: Article view count must not be negative
    errors << "Article view count must not be negative" if !(view_count >= 0)
    # Rule: Article likes count must not be negative
    errors << "Article likes count must not be negative" if !(likes_count >= 0)
    errors
  end

end

class ArticleTag
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property slug : String

  def rename(new_name : String)
    # TODO: implement rename
  end

  def article_count() : Int32
    # TODO: implement article_count
    0
  end

end

class ArticleTagAssignment
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property article_id : Int64?
  property tag_id : Int64?

end

class ArticleComment
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property body : String
  property is_hidden : Bool = false
  property article_id : Int64?
  property author_id : Int64?
  property parent_comment_id : Int64?

  def hide()
    # TODO: implement hide
  end

  def unhide()
    # TODO: implement unhide
  end

  def is_reply() : Bool
    # TODO: implement is_reply
    false
  end

end

class Stream
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property title : String
  property stream_url : String
  property status : String = "Scheduled"
  property platform : String = "Twitch"
  property language : String = "EN"
  property is_official : Bool = false
  property viewer_count_peak : Int32 = 0
  property scheduled_start : String
  property actual_start : String?
  property ended_at : String?
  property vod_url : String?
  property tournament_id : Int64?
  property streamer_id : Int64?

  def go_live()
    # TODO: implement go_live
  end

  def end()
    # TODO: implement end
  end

  def update_viewer_peak(count : Int32)
    # TODO: implement update_viewer_peak
  end

  def duration_minutes() : Int32
    # TODO: implement duration_minutes
    0
  end

  enum StreamStatus
    Scheduled
    Live
    Ended
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Ended"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: actual_start_requires_live_or_ended
    errors << "actual_start_requires_live_or_ended" if !(!(actual_start != nil) || (status == Live))
    # Rule: ended_at can only be set when stream status is Ended
    errors << "ended_at can only be set when stream status is Ended" if !(!(ended_at != nil) || (status == Ended))
    # Rule: Peak viewer count must not be negative
    errors << "Peak viewer count must not be negative" if !(viewer_count_peak >= 0)
    errors
  end

end
