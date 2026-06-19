(* Card model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  card_type : string;
  rarity : string;
  mana_cost : int;
  mana_colors : string;
  attack : int option;
  defense : int option;
  loyalty : int option;
  description : string;
  flavor_text : string option;
  image_url : string option;
  artist_name : string option;
  legal_formats : string;
  is_banned : bool;
  is_restricted : bool;
  power_level : int;
  set_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Card:
 *   has_many rulings -> CardRuling via card_id
 *   has_many abilities -> CardAbility via card_id
 *   many_to_many decks -> Deck through deck_cards
 *   many_to_many sideboard_decks -> Deck through deck_sideboard_cards
 *   has_many deck_cards -> DeckCard via card_id
 *   has_many sideboard_decks -> DeckSideboardCard via card_id
 *   has_many player_collections -> PlayerCollection via card_id
 *   has_many crafting_recipes -> CraftingRecipe via result_card_id
 *   has_many used_in_recipes -> CraftingIngredient via card_id
 *   has_one shop_product -> Product via card_id
 *   has_many trade_listings -> TradeListing via card_id
 *   has_many price_history -> CardPriceHistory via card_id
 *   has_many draft_picks -> DraftPick via card_id
 *)

(* ── Caqti query definitions for Card ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Card record *)
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), (v16, v17, v18, v19)) : t = {
  id = v0;
  name = v1;
  card_type = v2;
  rarity = v3;
  mana_cost = v4;
  mana_colors = v5;
  attack = v6;
  defense = v7;
  loyalty = v8;
  description = v9;
  flavor_text = v10;
  image_url = v11;
  artist_name = v12;
  legal_formats = v13;
  is_banned = v14;
  is_restricted = v15;
  power_level = v16;
  set_id = v17;
  created_at = v18;
  updated_at = v19;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string string string) (t4 int string (option int) (option int)) (t4 (option int) string (option string) (option string)) (t4 (option string) string bool bool)) (t4 int int string string)) @@
  {sql| SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, created_at, updated_at FROM cards ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string string string) (t4 int string (option int) (option int)) (t4 (option int) string (option string) (option string)) (t4 (option string) string bool bool)) (t4 int int string string)) @@
  {sql| SELECT id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id, created_at, updated_at FROM cards WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 (t4 string string string int) (t4 string (option int) (option int) (option int)) (t4 string (option string) (option string) (option string)) (t4 string bool bool int)) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO cards (name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 (t4 string string string int) (t4 string (option int) (option int) (option int)) (t4 string (option string) (option string) (option string)) (t4 string bool bool int)) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE cards SET name = ?, card_type = ?, rarity = ?, mana_cost = ?, mana_colors = ?, attack = ?, defense = ?, loyalty = ?, description = ?, flavor_text = ?, image_url = ?, artist_name = ?, legal_formats = ?, is_banned = ?, is_restricted = ?, power_level = ?, set_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM cards WHERE id = ? |sql}
