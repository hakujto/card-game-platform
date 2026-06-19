(* DraftSession model — record type + Caqti query definitions *)

type t = {
  id : int;
  status : string;
  draft_type : string;
  seats : int;
  time_per_pick_seconds : int;
  completed_at : string option;
  card_set_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for DraftSession:
 *   has_many participants -> DraftParticipant via session_id
 *)

(* ── Caqti query definitions for DraftSession ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DraftSession record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), v8) : t = {
  id = v0;
  status = v1;
  draft_type = v2;
  seats = v3;
  time_per_pick_seconds = v4;
  completed_at = v5;
  card_set_id = v6;
  created_at = v7;
  updated_at = v8;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string string int) (t4 int (option string) int string) string) @@
  {sql| SELECT id, status, draft_type, seats, time_per_pick_seconds, completed_at, card_set_id, created_at, updated_at FROM draft_sessions ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string string int) (t4 int (option string) int string) string) @@
  {sql| SELECT id, status, draft_type, seats, time_per_pick_seconds, completed_at, card_set_id, created_at, updated_at FROM draft_sessions WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string string int int) (t2 (option string) int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO draft_sessions (status, draft_type, seats, time_per_pick_seconds, completed_at, card_set_id) VALUES (?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string string int int) (t3 (option string) int int)) ->. Caqti_type.unit @@
  {sql| UPDATE draft_sessions SET status = ?, draft_type = ?, seats = ?, time_per_pick_seconds = ?, completed_at = ?, card_set_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM draft_sessions WHERE id = ? |sql}
