(* Friendship model — record type + Caqti query definitions *)

type t = {
  id : int;
  status : string;
  requester_id : int;
  receiver_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for Friendship ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Friendship record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5)) : t = {
  id = v0;
  status = v1;
  requester_id = v2;
  receiver_id = v3;
  created_at = v4;
  updated_at = v5;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string int int) (t2 string string)) @@
  {sql| SELECT id, status, requester_id, receiver_id, created_at, updated_at FROM friendships ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string int int) (t2 string string)) @@
  {sql| SELECT id, status, requester_id, receiver_id, created_at, updated_at FROM friendships WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 string int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO friendships (status, requester_id, receiver_id) VALUES (?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 string int int int) ->. Caqti_type.unit @@
  {sql| UPDATE friendships SET status = ?, requester_id = ?, receiver_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM friendships WHERE id = ? |sql}
