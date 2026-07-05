(* Tournament model — record type + Caqti query definitions *)

type t = {
  id : int;
  public_id : string;
  name : string;
  description : string option;
  status : string;
  bracket_data : string option;
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
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), (v16, v17, v18, v19)) : t = {
  id = v0;
  public_id = v1;
  name = v2;
  description = v3;
  status = v4;
  bracket_data = v5;
  format = v6;
  tournament_type = v7;
  max_players = v8;
  entry_fee = v9;
  prize_pool = v10;
  start_time = v11;
  end_time = v12;
  is_online = v13;
  location = v14;
  rules_text = v15;
  season_id = v16;
  organizer_id = v17;
  created_at = v18;
  updated_at = v19;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string string (option string)) (t4 string (option string) string string) (t4 int float float string) (t4 (option string) bool (option string) (option string))) (t4 int int string string)) @@
  {sql| SELECT id, public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string string (option string)) (t4 string (option string) string string) (t4 int float float string) (t4 (option string) bool (option string) (option string))) (t4 int int string string)) @@
  {sql| SELECT id, public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id, created_at, updated_at FROM tournaments WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 (t4 string string (option string) string) (t4 (option string) string string int) (t4 float float string (option string)) (t4 bool (option string) (option string) int)) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO tournaments (public_id, name, description, status, bracket_data, format, tournament_type, max_players, entry_fee, prize_pool, start_time, end_time, is_online, location, rules_text, season_id, organizer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 (t4 string string (option string) (option string)) (t4 string string int float) (t4 float string (option string) bool) (t4 (option string) (option string) int int)) int) ->. Caqti_type.unit @@
  {sql| UPDATE tournaments SET public_id = ?, name = ?, description = ?, bracket_data = ?, format = ?, tournament_type = ?, max_players = ?, entry_fee = ?, prize_pool = ?, start_time = ?, end_time = ?, is_online = ?, location = ?, rules_text = ?, season_id = ?, organizer_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM tournaments WHERE id = ? |sql}


(* ── Audit log for Tournament ── *)
type audit_log_t = {
  id : int;
  record_id : int;
  field : string;
  old_value : string option;
  new_value : string option;
  changed_by_id : int option;
  changed_at : string;
} [@@deriving yojson]

let audit_log_insert_q =
  Caqti_type.(t2 (t4 int string (option string) (option string)) (t2 (option int) string)) ->.
  Caqti_type.unit @@
  {sql| INSERT INTO tournament_audit_log (record_id, field, old_value, new_value, changed_by_id, changed_at) VALUES (?, ?, ?, ?, ?, ?) |sql}