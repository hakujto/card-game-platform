(* DeckCard model — record type + Caqti query definitions *)

type t = {
  id : int;
  quantity : int;
  is_commander : bool;
  deck_id : int;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for DeckCard ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DeckCard record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6)) : t = {
  id = v0;
  quantity = v1;
  is_commander = v2;
  deck_id = v3;
  card_id = v4;
  created_at = v5;
  updated_at = v6;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int bool int) (t3 int string string)) @@
  {sql| SELECT id, quantity, is_commander, deck_id, card_id, created_at, updated_at FROM deck_cards ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int bool int) (t3 int string string)) @@
  {sql| SELECT id, quantity, is_commander, deck_id, card_id, created_at, updated_at FROM deck_cards WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 int bool int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO deck_cards (quantity, is_commander, deck_id, card_id) VALUES (?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 int bool int int) int) ->. Caqti_type.unit @@
  {sql| UPDATE deck_cards SET quantity = ?, is_commander = ?, deck_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM deck_cards WHERE id = ? |sql}
