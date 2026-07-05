(* Game model — record type + Caqti query definitions *)

type t = {
  id : int;
  game_number : int;
  winner_side : string option;
  complexity_score : float option;
  turns_played : int option;
  duration_seconds : int option;
  ended_by : string option;
  replay_url : string option;
  match_id : int;
  winner_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for Game ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Game record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11)) : t = {
  id = v0;
  game_number = v1;
  winner_side = v2;
  complexity_score = v3;
  turns_played = v4;
  duration_seconds = v5;
  ended_by = v6;
  replay_url = v7;
  match_id = v8;
  winner_id = v9;
  created_at = v10;
  updated_at = v11;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int int (option string) (option float)) (t4 (option int) (option int) (option string) (option string)) (t4 int (option int) string string)) @@
  {sql| SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at FROM games ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int int (option string) (option float)) (t4 (option int) (option int) (option string) (option string)) (t4 int (option int) string string)) @@
  {sql| SELECT id, game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id, created_at, updated_at FROM games WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 int (option string) (option float) (option int)) (t4 (option int) (option string) (option string) int) (option int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO games (game_number, winner_side, complexity_score, turns_played, duration_seconds, ended_by, replay_url, match_id, winner_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 int (option string) (option float) (option int)) (t4 (option int) (option string) (option string) int) (t2 (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE games SET game_number = ?, winner_side = ?, complexity_score = ?, turns_played = ?, duration_seconds = ?, ended_by = ?, replay_url = ?, match_id = ?, winner_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM games WHERE id = ? |sql}
