(* TournamentRegistration model — record type + Caqti query definitions *)

type t = {
  id : int;
  status : string;
  seed : int option;
  final_standing : int option;
  points_earned : int;
  registered_at : string;
  tournament_id : int;
  player_id : int;
  deck_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for TournamentRegistration ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TournamentRegistration record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10)) : t = {
  id = v0;
  status = v1;
  seed = v2;
  final_standing = v3;
  points_earned = v4;
  registered_at = v5;
  tournament_id = v6;
  player_id = v7;
  deck_id = v8;
  created_at = v9;
  updated_at = v10;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string (option int) (option int)) (t4 int string int int) (t3 int string string)) @@
  {sql| SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at FROM tournament_registrations ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string (option int) (option int)) (t4 int string int int) (t3 int string string)) @@
  {sql| SELECT id, status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id, created_at, updated_at FROM tournament_registrations WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string (option int) (option int) int) (t4 string int int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO tournament_registrations (status, seed, final_standing, points_earned, registered_at, tournament_id, player_id, deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 string (option int) (option int) int) (t4 string int int int) int) ->. Caqti_type.unit @@
  {sql| UPDATE tournament_registrations SET status = ?, seed = ?, final_standing = ?, points_earned = ?, registered_at = ?, tournament_id = ?, player_id = ?, deck_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM tournament_registrations WHERE id = ? |sql}
