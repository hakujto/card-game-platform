(* CardSet model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  code : string;
  release_date : string;
  rotation_date : string option;
  set_type : string;
  total_cards : int;
  is_rotated : bool;
  description : string option;
  logo_url : string option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for CardSet ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the CardSet record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11)) : t = {
  id = v0;
  name = v1;
  code = v2;
  release_date = v3;
  rotation_date = v4;
  set_type = v5;
  total_cards = v6;
  is_rotated = v7;
  description = v8;
  logo_url = v9;
  created_at = v10;
  updated_at = v11;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string string string) (t4 (option string) string int bool) (t4 (option string) (option string) string string)) @@
  {sql| SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at FROM card_sets ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string string string) (t4 (option string) string int bool) (t4 (option string) (option string) string string)) @@
  {sql| SELECT id, name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url, created_at, updated_at FROM card_sets WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string string string (option string)) (t4 string int bool (option string)) (option string)) ->. Caqti_type.unit @@
  {sql| INSERT INTO card_sets (name, code, release_date, rotation_date, set_type, total_cards, is_rotated, description, logo_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 string string string (option string)) (t4 string int bool (option string)) (t2 (option string) int)) ->. Caqti_type.unit @@
  {sql| UPDATE card_sets SET name = ?, code = ?, release_date = ?, rotation_date = ?, set_type = ?, total_cards = ?, is_rotated = ?, description = ?, logo_url = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM card_sets WHERE id = ? |sql}
