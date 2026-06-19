(* DraftParticipant model — record type + Caqti query definitions *)

type t = {
  id : int;
  seat_number : int;
  joined_at : string;
  session_id : int;
  player_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for DraftParticipant:
 *   has_many picks -> DraftPick via participant_id
 *)

(* ── Caqti query definitions for DraftParticipant ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DraftParticipant record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6)) : t = {
  id = v0;
  seat_number = v1;
  joined_at = v2;
  session_id = v3;
  player_id = v4;
  created_at = v5;
  updated_at = v6;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int string int) (t3 int string string)) @@
  {sql| SELECT id, seat_number, joined_at, session_id, player_id, created_at, updated_at FROM draft_participants ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int string int) (t3 int string string)) @@
  {sql| SELECT id, seat_number, joined_at, session_id, player_id, created_at, updated_at FROM draft_participants WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 int string int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO draft_participants (seat_number, joined_at, session_id, player_id) VALUES (?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 int string int int) int) ->. Caqti_type.unit @@
  {sql| UPDATE draft_participants SET seat_number = ?, joined_at = ?, session_id = ?, player_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM draft_participants WHERE id = ? |sql}
