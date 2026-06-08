(* PlayerSeasonStats model — record type + Caqti query definitions *)

type t = {
  id : int;
  wins : int;
  losses : int;
  draws : int;
  tournament_wins : int;
  highest_rank : string option;
  season_points : int;
  player_id : int;
  season_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for PlayerSeasonStats ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the PlayerSeasonStats record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10)) : t = {
  id = v0;
  wins = v1;
  losses = v2;
  draws = v3;
  tournament_wins = v4;
  highest_rank = v5;
  season_points = v6;
  player_id = v7;
  season_id = v8;
  created_at = v9;
  updated_at = v10;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int int int int) (t4 int (option string) int int) (t3 int string string)) @@
  {sql| SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at FROM player_season_statses ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int int int int) (t4 int (option string) int int) (t3 int string string)) @@
  {sql| SELECT id, wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id, created_at, updated_at FROM player_season_statses WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int int int int) (t4 (option string) int int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO player_season_statses (wins, losses, draws, tournament_wins, highest_rank, season_points, player_id, season_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 int int int int) (t4 (option string) int int int) int) ->. Caqti_type.unit @@
  {sql| UPDATE player_season_statses SET wins = ?, losses = ?, draws = ?, tournament_wins = ?, highest_rank = ?, season_points = ?, player_id = ?, season_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM player_season_statses WHERE id = ? |sql}
