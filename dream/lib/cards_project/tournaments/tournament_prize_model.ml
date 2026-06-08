(* TournamentPrize model — record type + Caqti query definitions *)

type t = {
  id : int;
  placement_from : int;
  placement_to : int;
  prize_type : string;
  amount : float;
  description : string option;
  packs_count : int option;
  season_points : int;
  tournament_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for TournamentPrize ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TournamentPrize record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10)) : t = {
  id = v0;
  placement_from = v1;
  placement_to = v2;
  prize_type = v3;
  amount = v4;
  description = v5;
  packs_count = v6;
  season_points = v7;
  tournament_id = v8;
  created_at = v9;
  updated_at = v10;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int int int string) (t4 float (option string) (option int) int) (t3 int string string)) @@
  {sql| SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at FROM tournament_prizes ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int int int string) (t4 float (option string) (option int) int) (t3 int string string)) @@
  {sql| SELECT id, placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id, created_at, updated_at FROM tournament_prizes WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int int string float) (t4 (option string) (option int) int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO tournament_prizes (placement_from, placement_to, prize_type, amount, description, packs_count, season_points, tournament_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 int int string float) (t4 (option string) (option int) int int) int) ->. Caqti_type.unit @@
  {sql| UPDATE tournament_prizes SET placement_from = ?, placement_to = ?, prize_type = ?, amount = ?, description = ?, packs_count = ?, season_points = ?, tournament_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM tournament_prizes WHERE id = ? |sql}
