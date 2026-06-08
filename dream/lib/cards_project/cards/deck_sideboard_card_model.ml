(* DeckSideboardCard model — record type + Caqti query definitions *)

type t = {
  id : int;
  quantity : int;
  deck_id : int;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for DeckSideboardCard ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DeckSideboardCard record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5)) : t = {
  id = v0;
  quantity = v1;
  deck_id = v2;
  card_id = v3;
  created_at = v4;
  updated_at = v5;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int int int) (t2 string string)) @@
  {sql| SELECT id, quantity, deck_id, card_id, created_at, updated_at FROM deck_sideboard_cards ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int int int) (t2 string string)) @@
  {sql| SELECT id, quantity, deck_id, card_id, created_at, updated_at FROM deck_sideboard_cards WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 int int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO deck_sideboard_cards (quantity, deck_id, card_id) VALUES (?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 int int int int) ->. Caqti_type.unit @@
  {sql| UPDATE deck_sideboard_cards SET quantity = ?, deck_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM deck_sideboard_cards WHERE id = ? |sql}
