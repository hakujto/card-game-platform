require "db"
require "json"

class Player
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property public_id : String
  property display_name : String
  property rank : String = "Bronze"
  property rating : Int32 = 1000
  property peak_rating : Int32 = 1000
  property bio : String?
  property country_code : String?
  property avatar_url : String?
  property preferred_format : String?
  property contact_email : String?
  property win_rate_cached : Float64?
  property is_verified : Bool = false
  property last_active_at : String?
  property user_id : Int64?

  def promote() : Bool
    # TODO: implement promote
    false
  end

  def demote() : Bool
    # TODO: implement demote
    false
  end

  def record_win()
    # TODO: implement record_win
  end

  def record_loss()
    # TODO: implement record_loss
  end

  def win_rate() : Float64
    # TODO: implement win_rate
    0.0
  end

  def verify()
    # TODO: implement verify
  end

  def update_rating(delta : Int32)
    # TODO: implement update_rating
  end

  def after_create
    initialize_collection
  end

  def initialize_collection
    # TODO: implement initialize_collection
  end

  def validate
    errors = [] of String
    # Rule: Rating must be between 0 and 9999
    errors << "Rating must be between 0 and 9999" if !((rating >= 0 && rating <= 9999))
    # Rule: Peak rating must be greater than or equal to current rating
    errors << "Peak rating must be greater than or equal to current rating" if !(peak_rating >= rating)
    # Rule: Display name must not be empty
    errors << "Display name must not be empty" if !(display_name != nil)
    errors << "country_code does not match pattern" unless country_code.to_s.match(/[A-Z]{2}/)
    errors
  end

end

class PlayerSeasonStats
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property wins : Int32 = 0
  property losses : Int32 = 0
  property draws : Int32 = 0
  property tournament_wins : Int32 = 0
  property highest_rank : String?
  property season_points : Int32 = 0
  property player_id : Int64?
  property season_id : Int64?

  def win_rate() : Float64
    # TODO: implement win_rate
    0.0
  end

  def add_points(points : Int32)
    # TODO: implement add_points
  end

  def record_tournament_win()
    # TODO: implement record_tournament_win
  end

  def validate
    errors = [] of String
    # Rule: Season wins must not be negative
    errors << "Season wins must not be negative" if !(wins >= 0)
    # Rule: Season losses must not be negative
    errors << "Season losses must not be negative" if !(losses >= 0)
    # Rule: Season tournament wins must not be negative
    errors << "Season tournament wins must not be negative" if !(tournament_wins >= 0)
    # Rule: Season points must not be negative
    errors << "Season points must not be negative" if !(season_points >= 0)
    errors
  end

end

class PlayerCollection
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property quantity : Int32 = 1
  property foil : Bool = false
  property condition : String = "Mint"
  property acquired_at : String
  property acquired_via : String = "Purchase"
  property player_id : Int64?
  property card_id : Int64?

  def add(quantity : Int32)
    # TODO: implement add
  end

  def remove(quantity : Int32)
    # TODO: implement remove
  end

  def estimated_value() : Float64
    # TODO: implement estimated_value
    0.0
  end

  def validate
    errors = [] of String
    # Rule: Collection quantity must be greater than zero
    errors << "Collection quantity must be greater than zero" if !(quantity > 0)
    errors
  end

end

class Friendship
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property status : String = "Pending"
  property requester_id : Int64?
  property receiver_id : Int64?

  def accept()
    # TODO: implement accept
  end

  def decline()
    # TODO: implement decline
  end

  def block()
    # TODO: implement block
  end

end

class Achievement
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property description : String
  property icon_url : String?
  property points : Int32 = 10
  property rarity : String = "Common"
  property is_hidden : Bool = false

  def point_value(multiplier : Int32) : Int32
    # TODO: implement point_value
    0
  end

  def reveal()
    # TODO: implement reveal
  end

  def validate
    errors = [] of String
    # Rule: Achievement must award at least one point
    errors << "Achievement must award at least one point" if !(points > 0)
    errors
  end

end

class PlayerAchievement
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property earned_at : String
  property progress : Int32 = 0
  property is_completed : Bool = false
  property player_id : Int64?
  property achievement_id : Int64?

  def increment_progress(amount : Int32)
    # TODO: implement increment_progress
  end

  def complete()
    # TODO: implement complete
  end

  def validate
    errors = [] of String
    # Rule: Completed achievement must have progress greater than zero
    errors << "Completed achievement must have progress greater than zero" if !(!(is_completed == true) || (progress > 0))
    # Rule: Achievement progress must not be negative
    errors << "Achievement progress must not be negative" if !(progress >= 0)
    errors
  end

end

class CraftingRecipe
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property dust_cost : Int32
  property is_available : Bool = true
  property result_card_id : Int64?

  def can_craft(player_id : Int32) : Bool
    # TODO: implement can_craft
    false
  end

  def execute_craft(player_id : Int32)
    # TODO: implement execute_craft
  end

  def disable()
    # TODO: implement disable
  end

  def enable()
    # TODO: implement enable
  end

  def validate
    errors = [] of String
    # Rule: Crafting recipe must have a dust cost greater than zero
    errors << "Crafting recipe must have a dust cost greater than zero" if !(dust_cost > 0)
    errors
  end

end

class CraftingIngredient
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property quantity : Int32 = 1
  property recipe_id : Int64?
  property card_id : Int64?

end
