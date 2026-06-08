(* PlayerCollection model — record type + Caqti query definitions *)

type t = {
  id : int;
  quantity : int;
  foil : bool;
  condition : string;
  acquired_at : string;
  acquired_via : string;
  player_id : int;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for PlayerCollection ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the PlayerCollection record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9)) : t = {
  id = v0;
  quantity = v1;
  foil = v2;
  condition = v3;
  acquired_at = v4;
  acquired_via = v5;
  player_id = v6;
  card_id = v7;
  created_at = v8;
  updated_at = v9;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int int bool string) (t4 string string int int) (t2 string string)) @@
  {sql| SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at FROM player_collections ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int int bool string) (t4 string string int int) (t2 string string)) @@
  {sql| SELECT id, quantity, foil, condition, acquired_at, acquired_via, player_id, card_id, created_at, updated_at FROM player_collections WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int bool string string) (t3 string int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO player_collections (quantity, foil, condition, acquired_at, acquired_via, player_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 int bool string string) (t4 string int int int)) ->. Caqti_type.unit @@
  {sql| UPDATE player_collections SET quantity = ?, foil = ?, condition = ?, acquired_at = ?, acquired_via = ?, player_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM player_collections WHERE id = ? |sql}
