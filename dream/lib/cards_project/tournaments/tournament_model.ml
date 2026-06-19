(* Tournament model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  description : string option;
  status : string;
  format : string;
  tournament_type : string;
  max_players : int;
  entry_fee : float;
  prize_pool : float;
  start_time : string;
  end_time : string option;
  is_online : bool;
  location : string option;
  rules_text : string option;
  season_id : int;
  organizer_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Tournament:
 *   has_many judge_assignments -> TournamentJudge via tournament_id
 *   has_many registrations -> TournamentRegistration via tournament_id
 *   has_many rounds -> TournamentRound via tournament_id
 *   has_many prizes -> TournamentPrize via tournament_id
 *   has_many streams -> Stream via tournament_id
 *)

(* ── Caqti query definitions for Tournament ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Tournament record *)
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), (v16, v17)) : t = {
  id = v0;
  name = v1;
  description = v2;
  status = v3;
  format = v4;
  tournament_type = v5;
  max_players = v6;
  entry_fee = v7;
  prize_pool = v8;
  start_time = v9;
  end_time = v10;
  is_online = v11;
  location = v12;
  rules_text = v13;
  season_id = v14;
  organizer_id = v15;
  created_at = v16;
  updated_at = v17;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string (option string) string) (t4 string string int float) (t4 float string (option string) bool) (t4 (option string) (option string) int int)) (t2 string string)) @@
  {sql| SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string (option string) string) (t4 string string int float) (t4 float string (option string) bool) (t4 (option string) (option string) int int)) (t2 string string)) @@
  {sql| SELECT id, name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 (t4 string (option string) string string) (t4 string int float float) (t4 string (option string) bool (option string)) (t3 (option string) int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO tournaments (name, description, status, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 (t4 string (option string) string string) (t4 string int float float) (t4 string (option string) bool (option string)) (t4 (option string) int int int)) ->. Caqti_type.unit @@
  {sql| UPDATE tournaments SET name = ?, description = ?, status = ?, format = ?, tournament_type = ?, max_players = ?, entry_fee = ?, prize_pool = ?, start_time = ?, end_time = ?, is_online = ?, location = ?, rules_text = ?, season_id = ?, organizer_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM tournaments WHERE id = ? |sql}
