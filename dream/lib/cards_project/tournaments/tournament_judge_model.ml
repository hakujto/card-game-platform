(* TournamentJudge model — record type + Caqti query definitions *)

type t = {
  id : int;
  role : string;
  tournament_id : int;
  player_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for TournamentJudge ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TournamentJudge record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5)) : t = {
  id = v0;
  role = v1;
  tournament_id = v2;
  player_id = v3;
  created_at = v4;
  updated_at = v5;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string int int) (t2 string string)) @@
  {sql| SELECT id, role, tournament_id, player_id, created_at, updated_at FROM tournament_judges ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string int int) (t2 string string)) @@
  {sql| SELECT id, role, tournament_id, player_id, created_at, updated_at FROM tournament_judges WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 string int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO tournament_judges (role, tournament_id, player_id) VALUES (?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 string int int int) ->. Caqti_type.unit @@
  {sql| UPDATE tournament_judges SET role = ?, tournament_id = ?, player_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM tournament_judges WHERE id = ? |sql}
