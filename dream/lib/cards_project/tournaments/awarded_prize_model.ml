(* AwardedPrize model — record type + Caqti query definitions *)

type t = {
  id : int;
  final_placement : int;
  awarded_at : string;
  claimed : bool;
  claimed_at : string option;
  prize_id : int;
  player_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for AwardedPrize ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the AwardedPrize record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), v8) : t = {
  id = v0;
  final_placement = v1;
  awarded_at = v2;
  claimed = v3;
  claimed_at = v4;
  prize_id = v5;
  player_id = v6;
  created_at = v7;
  updated_at = v8;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int int string bool) (t4 (option string) int int string) string) @@
  {sql| SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at FROM awarded_prizes ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int int string bool) (t4 (option string) int int string) string) @@
  {sql| SELECT id, final_placement, awarded_at, claimed, claimed_at, prize_id, player_id, created_at, updated_at FROM awarded_prizes WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int string bool (option string)) (t2 int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO awarded_prizes (final_placement, awarded_at, claimed, claimed_at, prize_id, player_id) VALUES (?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 bool (option string) int int) int) ->. Caqti_type.unit @@
  {sql| UPDATE awarded_prizes SET claimed = ?, claimed_at = ?, prize_id = ?, player_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM awarded_prizes WHERE id = ? |sql}
