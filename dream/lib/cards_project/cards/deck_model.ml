(* Deck model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  description : string option;
  format : string;
  is_public : bool;
  is_tournament_legal : bool;
  archetype : string option;
  wins : int;
  losses : int;
  draws : int;
  player_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Deck:
 *   has_many deck_cards -> DeckCard via deck_id
 *   has_many sideboard_cards -> DeckSideboardCard via deck_id
 *   has_many tag_assignments -> DeckTagAssignment via deck_id
 *   has_many tournament_registrations -> TournamentRegistration via deck_id
 *   has_many articles -> Article via featured_deck_id
 *)

(* ── Caqti query definitions for Deck ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Deck record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), v12) : t = {
  id = v0;
  name = v1;
  description = v2;
  format = v3;
  is_public = v4;
  is_tournament_legal = v5;
  archetype = v6;
  wins = v7;
  losses = v8;
  draws = v9;
  player_id = v10;
  created_at = v11;
  updated_at = v12;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int string (option string) string) (t4 bool bool (option string) int) (t4 int int int string) string) @@
  {sql| SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at FROM decks ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int string (option string) string) (t4 bool bool (option string) int) (t4 int int int string) string) @@
  {sql| SELECT id, name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id, created_at, updated_at FROM decks WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string (option string) string bool) (t4 bool (option string) int int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO decks (name, description, format, is_public, is_tournament_legal, archetype, wins, losses, draws, player_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string (option string) string bool) (t4 bool (option string) int int)) ->. Caqti_type.unit @@
  {sql| UPDATE decks SET name = ?, description = ?, format = ?, is_public = ?, is_tournament_legal = ?, archetype = ?, player_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM decks WHERE id = ? |sql}
