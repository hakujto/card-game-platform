(* DraftPick model — record type + Caqti query definitions *)

type t = {
  id : int;
  pick_number : int;
  pack_number : int;
  picked_at : string;
  participant_id : int;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for DraftPick ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DraftPick record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7)) : t = {
  id = v0;
  pick_number = v1;
  pack_number = v2;
  picked_at = v3;
  participant_id = v4;
  card_id = v5;
  created_at = v6;
  updated_at = v7;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int int string) (t4 int int string string)) @@
  {sql| SELECT id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at FROM draft_picks ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int int string) (t4 int int string string)) @@
  {sql| SELECT id, pick_number, pack_number, picked_at, participant_id, card_id, created_at, updated_at FROM draft_picks WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int int string int) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO draft_picks (pick_number, pack_number, picked_at, participant_id, card_id) VALUES (?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 int int string int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE draft_picks SET pick_number = ?, pack_number = ?, picked_at = ?, participant_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM draft_picks WHERE id = ? |sql}
