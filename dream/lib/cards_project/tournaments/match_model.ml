(* Match model — record type + Caqti query definitions *)

type t = {
  id : int;
  table_number : int option;
  status : string;
  player1_wins : int;
  player2_wins : int;
  started_at : string option;
  ended_at : string option;
  result_notes : string option;
  round_id : int;
  player1_id : int;
  player2_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Match:
 *   has_many games -> Game via match_id
 *)

(* ── Caqti query definitions for Match ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Match record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), v12) : t = {
  id = v0;
  table_number = v1;
  status = v2;
  player1_wins = v3;
  player2_wins = v4;
  started_at = v5;
  ended_at = v6;
  result_notes = v7;
  round_id = v8;
  player1_id = v9;
  player2_id = v10;
  created_at = v11;
  updated_at = v12;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int (option int) string int) (t4 int (option string) (option string) (option string)) (t4 int int (option int) string) string) @@
  {sql| SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, created_at, updated_at FROM matches ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int (option int) string int) (t4 int (option string) (option string) (option string)) (t4 int int (option int) string) string) @@
  {sql| SELECT id, table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id, created_at, updated_at FROM matches WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 (option int) string int int) (t4 (option string) (option string) (option string) int) (t2 int (option int))) ->. Caqti_type.unit @@
  {sql| INSERT INTO matches (table_number, status, player1_wins, player2_wins, started_at, ended_at, result_notes, round_id, player1_id, player2_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 (option int) string int int) (t4 (option string) (option string) (option string) int) (t3 int (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE matches SET table_number = ?, status = ?, player1_wins = ?, player2_wins = ?, started_at = ?, ended_at = ?, result_notes = ?, round_id = ?, player1_id = ?, player2_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM matches WHERE id = ? |sql}
