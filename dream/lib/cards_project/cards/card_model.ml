(* Card model — record type + Caqti query definitions *)

type t = {
  id : int;
  public_id : string;
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
  metadata : string option;
  total_copies_in_circulation : int;
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
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), ((v16, v17, v18, v19), (v20, v21, v22))) : t = {
  id = v0;
  public_id = v1;
  name = v2;
  card_type = v3;
  rarity = v4;
  mana_cost = v5;
  mana_colors = v6;
  attack = v7;
  defense = v8;
  loyalty = v9;
  description = v10;
  flavor_text = v11;
  image_url = v12;
  artist_name = v13;
  legal_formats = v14;
  is_banned = v15;
  is_restricted = v16;
  power_level = v17;
  metadata = v18;
  total_copies_in_circulation = v19;
  set_id = v20;
  created_at = v21;
  updated_at = v22;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string string string) (t4 string int string (option int)) (t4 (option int) (option int) string (option string)) (t4 (option string) (option string) string bool)) (t2 (t4 bool int (option string) int) (t3 int string string))) @@
  {sql| SELECT id, public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id, created_at, updated_at FROM cards ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string string string) (t4 string int string (option int)) (t4 (option int) (option int) string (option string)) (t4 (option string) (option string) string bool)) (t2 (t4 bool int (option string) int) (t3 int string string))) @@
  {sql| SELECT id, public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id, created_at, updated_at FROM cards WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 (t4 string string string string) (t4 int string (option int) (option int)) (t4 (option int) string (option string) (option string)) (t4 (option string) string bool bool)) (t4 int (option string) int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO cards (public_id, name, card_type, rarity, mana_cost, mana_colors, attack, defense, loyalty, description, flavor_text, image_url, artist_name, legal_formats, is_banned, is_restricted, power_level, metadata, total_copies_in_circulation, set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 (t4 string string string string) (t4 int string (option int) (option int)) (t4 (option int) string (option string) (option string)) (t4 (option string) string int (option string))) (t3 int int int)) ->. Caqti_type.unit @@
  {sql| UPDATE cards SET public_id = ?, name = ?, card_type = ?, rarity = ?, mana_cost = ?, mana_colors = ?, attack = ?, defense = ?, loyalty = ?, description = ?, flavor_text = ?, image_url = ?, artist_name = ?, legal_formats = ?, power_level = ?, metadata = ?, total_copies_in_circulation = ?, set_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM cards WHERE id = ? |sql}


(* ── Audit log for Card ── *)
type audit_log_t = {
  id : int;
  record_id : int;
  field : string;
  old_value : string option;
  new_value : string option;
  changed_by_id : int option;
  changed_at : string;
} [@@deriving yojson]

let audit_log_insert_q =
  Caqti_type.(t2 (t4 int string (option string) (option string)) (t2 (option int) string)) ->.
  Caqti_type.unit @@
  {sql| INSERT INTO card_audit_log (record_id, field, old_value, new_value, changed_by_id, changed_at) VALUES (?, ?, ?, ?, ?, ?) |sql}