(* TournamentRound model — record type + Caqti query definitions *)

type t = {
  id : int;
  round_number : int;
  status : string;
  started_at : string option;
  ended_at : string option;
  time_limit_minutes : int;
  tournament_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for TournamentRound ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TournamentRound record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), v8) : t = {
  id = v0;
  round_number = v1;
  status = v2;
  started_at = v3;
  ended_at = v4;
  time_limit_minutes = v5;
  tournament_id = v6;
  created_at = v7;
  updated_at = v8;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int int string (option string)) (t4 (option string) int int string) string) @@
  {sql| SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, created_at, updated_at FROM tournament_rounds ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int int string (option string)) (t4 (option string) int int string) string) @@
  {sql| SELECT id, round_number, status, started_at, ended_at, time_limit_minutes, tournament_id, created_at, updated_at FROM tournament_rounds WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int string (option string) (option string)) (t2 int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO tournament_rounds (round_number, status, started_at, ended_at, time_limit_minutes, tournament_id) VALUES (?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 int string (option string) (option string)) (t3 int int int)) ->. Caqti_type.unit @@
  {sql| UPDATE tournament_rounds SET round_number = ?, status = ?, started_at = ?, ended_at = ?, time_limit_minutes = ?, tournament_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM tournament_rounds WHERE id = ? |sql}
