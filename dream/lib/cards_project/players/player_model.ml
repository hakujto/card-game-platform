(* Player model — record type + Caqti query definitions *)

type t = {
  id : int;
  display_name : string;
  rank : string;
  rating : int;
  peak_rating : int;
  bio : string option;
  country_code : string option;
  avatar_url : string option;
  preferred_format : string option;
  is_verified : bool;
  last_active_at : string option;
  user_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for Player ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Player record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13)) : t = {
  id = v0;
  display_name = v1;
  rank = v2;
  rating = v3;
  peak_rating = v4;
  bio = v5;
  country_code = v6;
  avatar_url = v7;
  preferred_format = v8;
  is_verified = v9;
  last_active_at = v10;
  user_id = v11;
  created_at = v12;
  updated_at = v13;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int string string int) (t4 int (option string) (option string) (option string)) (t4 (option string) bool (option string) (option int)) (t2 string string)) @@
  {sql| SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id, created_at, updated_at FROM players ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int string string int) (t4 int (option string) (option string) (option string)) (t4 (option string) bool (option string) (option int)) (t2 string string)) @@
  {sql| SELECT id, display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id, created_at, updated_at FROM players WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string string int int) (t4 (option string) (option string) (option string) (option string)) (t3 bool (option string) (option int))) ->. Caqti_type.unit @@
  {sql| INSERT INTO players (display_name, rank, rating, peak_rating, bio, country_code, avatar_url, preferred_format, is_verified, last_active_at, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 string string int int) (t4 (option string) (option string) (option string) (option string)) (t4 bool (option string) (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE players SET display_name = ?, rank = ?, rating = ?, peak_rating = ?, bio = ?, country_code = ?, avatar_url = ?, preferred_format = ?, is_verified = ?, last_active_at = ?, user_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM players WHERE id = ? |sql}
