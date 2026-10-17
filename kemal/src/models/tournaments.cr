require "db"
require "json"

class Season
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property start_date : String
  property end_date : String
  property format : String = "Standard"
  property is_active : Bool = false
  property reward_description : String?

  def activate()
    # TODO: implement activate
  end

  def deactivate()
    # TODO: implement deactivate
  end

  def finalize_rewards()
    # TODO: implement finalize_rewards
  end

  def is_ongoing() : Bool
    # TODO: implement is_ongoing
    false
  end

  def validate
    errors = [] of String
    # Rule: Season end date must be after start date
    errors << "Season end date must be after start date" if !(end_date > start_date)
    errors
  end

end

class Tournament
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property public_id : String
  property name : String
  property description : String?
  property status : String = "Draft"
  property bracket_data : String?
  property format : String = "Standard"
  property tournament_type : String = "Swiss"
  property max_players : Int32
  property entry_fee : Float64 = 0.0
  property prize_pool : Float64 = 0.0
  property start_time : String
  property end_time : String?
  property is_online : Bool = true
  property location : String?
  property rules_text : String?
  property season_id : Int64?
  property organizer_id : Int64?
  property created_by : Int64?
  property updated_by : Int64?

  def start()
    # TODO: implement start
  end

  def cancel()
    # TODO: implement cancel
  end

  def complete()
    # TODO: implement complete
  end

  def generate_round()
    # TODO: implement generate_round
  end

  def calculate_prize_distribution() : Float64
    # TODO: implement calculate_prize_distribution
    0.0
  end

  def register_player(player_id : Int32, deck_id : Int32)
    # TODO: implement register_player
  end

  def is_full() : Bool
    # TODO: implement is_full
    false
  end

  enum TournamentStatus
    Draft
    Registration
    Ongoing
    Completed
    Cancelled
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Completed", "Cancelled"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: Tournament must allow between 2 and 512 players
    errors << "Tournament must allow between 2 and 512 players" if !((max_players >= 2 && max_players <= 512))
    # Rule: Entry fee must not be negative
    errors << "Entry fee must not be negative" if !(entry_fee >= 0)
    # Rule: Prize pool must not be negative
    errors << "Prize pool must not be negative" if !(prize_pool >= 0)
    # Rule: End time must be after start time
    errors << "End time must be after start time" if !(!(end_time != nil) || (end_time > start_time))
    errors << "max_players must be >= 2" if max_players < 2
    errors << "max_players must be <= 512" if max_players > 512
    errors
  end

end

class TournamentJudge
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property role : String = "Judge"
  property tournament_id : Int64?
  property player_id : Int64?

  def promote_to_head()
    # TODO: implement promote_to_head
  end

  def remove()
    # TODO: implement remove
  end

end

class TournamentRegistration
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property status : String = "Registered"
  property seed : Int32?
  property final_standing : Int32?
  property points_earned : Int32 = 0
  property registered_at : String
  property tournament_id : Int64?
  property player_id : Int64?
  property deck_id : Int64?

  def withdraw()
    # TODO: implement withdraw
  end

  def disqualify(reason : String)
    # TODO: implement disqualify
  end

  def promote_from_waitlist()
    # TODO: implement promote_from_waitlist
  end

  def validate
    errors = [] of String
    # Rule: Points earned must not be negative
    errors << "Points earned must not be negative" if !(points_earned >= 0)
    # Rule: Final standing must be greater than zero
    errors << "Final standing must be greater than zero" if !(!(final_standing != nil) || (final_standing > 0))
    # Rule: Seed must be greater than zero
    errors << "Seed must be greater than zero" if !(!(seed != nil) || (seed > 0))
    errors
  end

end

class TournamentRound
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property round_number : Int32
  property status : String = "Pending"
  property started_at : String?
  property ended_at : String?
  property time_limit_minutes : Int32 = 50
  property tournament_id : Int64?

  def start()
    # TODO: implement start
  end

  def complete()
    # TODO: implement complete
  end

  def generate_pairings()
    # TODO: implement generate_pairings
  end

  def is_time_expired() : Bool
    # TODO: implement is_time_expired
    false
  end

  def validate
    errors = [] of String
    # Rule: Round end time must be after start time
    errors << "Round end time must be after start time" if !(!(ended_at != nil) || (ended_at > started_at))
    # Rule: Completed round must have a start time
    errors << "Completed round must have a start time" if !(!(status == Completed) || (started_at != nil))
    # Rule: Round number must be greater than zero
    errors << "Round number must be greater than zero" if !(round_number > 0)
    # Rule: Round time limit must be greater than zero
    errors << "Round time limit must be greater than zero" if !(time_limit_minutes > 0)
    errors
  end

end

class Match
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property table_number : Int32?
  property status : String = "Pending"
  property player1_wins : Int32 = 0
  property player2_wins : Int32 = 0
  property started_at : String?
  property ended_at : String?
  property result_notes : String?
  property round_id : Int64?
  property player1_id : Int64?
  property player2_id : Int64?

  def record_result(p1_wins : Int32, p2_wins : Int32)
    # TODO: implement record_result
    determine_winner
  end

  def finalize_result()
    # TODO: implement finalize_result
    determine_winner
  end

  def determine_winner() : Bool
    # TODO: implement determine_winner
    false
  end

  def concede(player_id : Int32)
    raise "Guard failed: status == Active" unless status == Active
    # TODO: implement concede
  end

  def draw()
    # TODO: implement draw
  end

  enum MatchStatus
    Pending
    Active
    Completed
    BYE
    Draw
  end

  def transition_to(new_status : String)
    raise "Transition denied" if ["Completed", "Draw", "BYE"].includes?(status.to_s)
    # TODO: validate transition
    self.status = new_status
  end

  def validate
    errors = [] of String
    # Rule: Win counts must not be negative
    errors << "Win counts must not be negative" if !((player1_wins >= 0) && (player2_wins >= 0))
    # Rule: Win counts cannot exceed 2 in a best-of-3 match
    errors << "Win counts cannot exceed 2 in a best-of-3 match" if !(((player1_wins >= 0 && player1_wins <= 2)) && ((player2_wins >= 0 && player2_wins <= 2)))
    # Rule: BYE match must not have a second player
    errors << "BYE match must not have a second player" if !(!(status == BYE) || (player2 == nil))
    # Rule: Match end time must be after start time
    errors << "Match end time must be after start time" if !(!(ended_at != nil) || (ended_at > started_at))
    # Rule: Completed match must have a start time
    errors << "Completed match must have a start time" if !(!(status == Completed) || (started_at != nil))
    errors
  end

end

class Game
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property game_number : Int32
  property winner_side : String?
  property complexity_score : Float64?
  property turns_played : Int32?
  property duration_seconds : Int32?
  property ended_by : String?
  property replay_url : String?
  property match_id : Int64?
  property winner_id : Int64?

  def record_winner(winner_side : String)
    # TODO: implement record_winner
  end

  def duration_minutes() : Float64
    # TODO: implement duration_minutes
    0.0
  end

  def validate
    errors = [] of String
    # Rule: Game number must be between 1 and 3 (best-of-3)
    errors << "Game number must be between 1 and 3 (best-of-3)" if !((game_number >= 1 && game_number <= 3))
    # Rule: Turns played must be greater than zero
    errors << "Turns played must be greater than zero" if !(!(turns_played != nil) || (turns_played > 0))
    # Rule: Game duration must be greater than zero
    errors << "Game duration must be greater than zero" if !(!(duration_seconds != nil) || (duration_seconds > 0))
    # Rule: A draw cannot have a winner
    errors << "A draw cannot have a winner" if !(!(winner_side == Draw) || (winner == nil))
    # Rule: A decisive game must have a winner player set
    errors << "A decisive game must have a winner player set" if !(!((winner_side != nil) && (winner_side != Draw)) || (winner != nil))
    errors << "game_number must be >= 1" if game_number < 1
    errors << "game_number must be <= 3" if game_number > 3
    errors
  end

end

class TournamentPrize
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property placement_from : Int32
  property placement_to : Int32
  property prize_type : String
  property amount : Float64 = 0.0
  property description : String?
  property packs_count : Int32?
  property season_points : Int32 = 0
  property tournament_id : Int64?

  def applies_to_placement(placement : Int32) : Bool
    # TODO: implement applies_to_placement
    false
  end

  def award_to_player(player_id : Int32)
    # TODO: implement award_to_player
  end

  def validate
    errors = [] of String
    # Rule: placement_to must be greater than or equal to placement_from
    errors << "placement_to must be greater than or equal to placement_from" if !(placement_to >= placement_from)
    # Rule: placement_from must be greater than zero
    errors << "placement_from must be greater than zero" if !(placement_from > 0)
    # Rule: Prize amount must not be negative
    errors << "Prize amount must not be negative" if !(amount >= 0)
    errors << "placement_from must be >= 1" if placement_from < 1
    errors << "placement_to must be >= 1" if placement_to < 1
    errors
  end

end

class AwardedPrize
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property final_placement : Int32
  property awarded_at : String
  property claimed : Bool = false
  property claimed_at : String?
  property prize_id : Int64?
  property player_id : Int64?

  def claim()
    # TODO: implement claim
  end

  def validate
    errors = [] of String
    # Rule: Claimed prize must have a claimed_at timestamp
    errors << "Claimed prize must have a claimed_at timestamp" if !(!(claimed == true) || (claimed_at != nil))
    # Rule: Final placement must be greater than zero
    errors << "Final placement must be greater than zero" if !(final_placement > 0)
    # @required_when: {"type":"eq","field":"claimed","value":"true"}
    errors << "claimed_at is required" if claimed_at.nil?
    errors
  end

end
