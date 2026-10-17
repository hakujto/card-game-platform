require "db"
require "json"

class Card
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property public_id : String
  property name : String
  property card_type : String = "Creature"
  property rarity : String = "Common"
  property mana_cost : Int32 = 0
  property mana_colors : String
  property attack : Int32?
  property defense : Int32?
  property loyalty : Int32?
  property description : String
  property flavor_text : String?
  property image_url : String?
  property artist_name : String?
  property legal_formats : String
  property is_banned : Bool = false
  property is_restricted : Bool = false
  property power_level : Int32 = 1
  property metadata : String?
  property total_copies_in_circulation : Int64 = 0
  property set_id : Int64?
  property created_by : Int64?
  property updated_by : Int64?

  def ban()
    # TODO: implement ban
  end

  def unban()
    # TODO: implement unban
  end

  def restrict()
    # TODO: implement restrict
  end

  def unrestrict()
    # TODO: implement unrestrict
  end

  def replace(data : String) : Bool
    # TODO: implement replace
    false
  end

  def calculate_value() : Float64
    # TODO: implement calculate_value
    0.0
  end

  def apply_rarity_bonus(multiplier : Int32) : Float64
    # TODO: implement apply_rarity_bonus
    0.0
  end

  def is_legal_in_format(format : String) : Bool
    # TODO: implement is_legal_in_format
    false
  end

  def before_save
    validate_legality
  end

  def validate_legality
    # TODO: implement validate_legality
  end

  def validate
    errors = [] of String
    # Rule: Creature card must have attack and defense
    errors << "Creature card must have attack and defense" if !(!(card_type == Creature) || (attack != nil && defense != nil))
    # Rule: Planeswalker card must have loyalty
    errors << "Planeswalker card must have loyalty" if !(!(card_type == Planeswalker) || (loyalty != nil))
    # Rule: Land card must have zero mana cost
    errors << "Land card must have zero mana cost" if !(!(card_type == Land) || (mana_cost == 0))
    # Rule: Only Planeswalker cards can have loyalty
    errors << "Only Planeswalker cards can have loyalty" if !(!(card_type != Planeswalker) || (loyalty == nil))
    # Rule: mana_cost must be between 0 and 20
    errors << "mana_cost must be between 0 and 20" if !((mana_cost >= 0 && mana_cost <= 20))
    # Rule: power_level must be between 1 and 10
    errors << "power_level must be between 1 and 10" if !((power_level >= 1 && power_level <= 10))
    # Rule: Card cannot be both banned and restricted at the same time
    errors << "Card cannot be both banned and restricted at the same time" if !(!((is_banned == true) && (is_restricted == true)))
    # Rule: Banned card must not appear in any legal formats
    errors << "Banned card must not appear in any legal formats" if !(!(is_banned == true) || (legal_formats.empty?))
    errors << "mana_cost must be >= 0" if mana_cost < 0
    errors << "mana_cost must be <= 20" if mana_cost > 20
    errors << "power_level must be >= 1" if power_level < 1
    errors << "power_level must be <= 10" if power_level > 10
    # @required_when: {"type":"eq","field":"card_type","value":"Creature"}
    errors << "attack is required" if attack.nil?
    # @required_when: {"type":"eq","field":"card_type","value":"Creature"}
    errors << "defense is required" if defense.nil?
    # @required_when: {"type":"eq","field":"card_type","value":"Planeswalker"}
    errors << "loyalty is required" if loyalty.nil?
    errors
  end

end

class CardSet
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property code : String
  property release_date : String
  property rotation_date : String?
  property set_type : String = "Expansion"
  property total_cards : Int32
  property is_rotated : Bool = false
  property description : String?
  property logo_url : String?

  def is_legal_in_standard() : Bool
    # TODO: implement is_legal_in_standard
    false
  end

  def is_legal_in_format(format : String) : Bool
    # TODO: implement is_legal_in_format
    false
  end

  def card_count_by_rarity(rarity : String) : Int32
    # TODO: implement card_count_by_rarity
    0
  end

  def rotate_out()
    # TODO: implement rotate_out
  end

  def validate
    errors = [] of String
    # Rule: Card set must have at least one card
    errors << "Card set must have at least one card" if !(total_cards > 0)
    # Rule: Rotation date must be after release date
    errors << "Rotation date must be after release date" if !(!(rotation_date != nil) || (rotation_date > release_date))
    # Rule: Rotated set must have a rotation date
    errors << "Rotated set must have a rotation date" if !(!(is_rotated == true) || (rotation_date != nil))
    errors << "code does not match pattern" unless code.to_s.match(/[A-Z]{2,6}/)
    errors
  end

end

class CardRuling
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property ruling_text : String
  property published_at : String
  property source : String
  property card_id : Int64?

  def is_current() : Bool
    # TODO: implement is_current
    false
  end

  def supersedes_previous() : Bool
    # TODO: implement supersedes_previous
    false
  end

end

class CardAbility
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property ability_type : String = "Keyword"
  property keyword : String?
  property ability_text : String
  property timing : String?
  property card_id : Int64?

  def is_usable_at(timing : String) : Bool
    # TODO: implement is_usable_at
    false
  end

  def describe() : String
    # TODO: implement describe
    ""
  end

  def validate
    errors = [] of String
    # Rule: Keyword ability must have a keyword name
    errors << "Keyword ability must have a keyword name" if !(!(ability_type == Keyword) || (keyword != nil))
    errors
  end

end

class Deck
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property description : String?
  property format : String = "Standard"
  property is_public : Bool = false
  property is_tournament_legal : Bool = false
  property archetype : String?
  property wins : Int32 = 0
  property losses : Int32 = 0
  property draws : Int32 = 0
  property player_id : Int64?

  def validate_size() : Bool
    # TODO: implement validate_size
    false
  end

  def add_card(card_id : Int32, quantity : Int32)
    # TODO: implement add_card
  end

  def remove_card(card_id : Int32)
    # TODO: implement remove_card
  end

  def win_rate() : Float64
    # TODO: implement win_rate
    0.0
  end

  def clone() : String
    # TODO: implement clone
    nil
  end

  def publish()
    # TODO: implement publish
  end

  def unpublish()
    # TODO: implement unpublish
  end

  def certify_tournament_legal() : Bool
    # TODO: implement certify_tournament_legal
    false
  end

  def validate
    errors = [] of String
    # Rule: Deck wins count must not be negative
    errors << "Deck wins count must not be negative" if !(wins >= 0)
    # Rule: Deck losses count must not be negative
    errors << "Deck losses count must not be negative" if !(losses >= 0)
    # Rule: Deck draws count must not be negative
    errors << "Deck draws count must not be negative" if !(draws >= 0)
    # Rule: Tournament-legal deck must be made public
    errors << "Tournament-legal deck must be made public" if !(!(is_tournament_legal == true) || (is_public == true))
    errors
  end

end

class DeckCard
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property quantity : Int32 = 1
  property is_commander : Bool = false
  property deck_id : Int64?
  property card_id : Int64?

  def increment(amount : Int32)
    # TODO: implement increment
  end

  def decrement(amount : Int32)
    # TODO: implement decrement
  end

  def validate
    errors = [] of String
    # Rule: A deck can contain between 1 and 4 copies of a card
    errors << "A deck can contain between 1 and 4 copies of a card" if !((quantity >= 1 && quantity <= 4))
    # Rule: Commander card must appear exactly once in the deck
    errors << "Commander card must appear exactly once in the deck" if !(!(is_commander == true) || (quantity == 1))
    errors << "quantity must be >= 1" if quantity < 1
    errors << "quantity must be <= 4" if quantity > 4
    errors
  end

end

class DeckSideboardCard
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property quantity : Int32 = 1
  property deck_id : Int64?
  property card_id : Int64?

  def increment(amount : Int32)
    # TODO: implement increment
  end

  def decrement(amount : Int32)
    # TODO: implement decrement
  end

  def validate
    errors = [] of String
    # Rule: Sideboard card quantity must be between 1 and 4 copies
    errors << "Sideboard card quantity must be between 1 and 4 copies" if !((quantity >= 1 && quantity <= 4))
    errors
  end

end

class DeckTag
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property name : String
  property slug : String?
  property color : String?

  def rename(new_name : String)
    # TODO: implement rename
  end

  def merge_into(target_tag_id : Int32)
    # TODO: implement merge_into
  end

end

class DeckTagAssignment
  include DB::Serializable
  include JSON::Serializable

  property id : Int64?
  property created_at : String?
  property updated_at : String?
  property deck_id : Int64?
  property tag_id : Int64?

end
