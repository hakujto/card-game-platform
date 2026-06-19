(* Season model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  start_date : string;
  end_date : string;
  format : string;
  is_active : bool;
  reward_description : string option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Season:
 *   has_many player_stats -> PlayerSeasonStats via season_id
 *   has_many tournaments -> Tournament via season_id
 *)

(* ── Caqti query definitions for Season ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Season record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), v8) : t = {
  id = v0;
  name = v1;
  start_date = v2;
  end_date = v3;
  format = v4;
  is_active = v5;
  reward_description = v6;
  created_at = v7;
  updated_at = v8;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string string string) (t4 string bool (option string) string) string) @@
  {sql| SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string string string) (t4 string bool (option string) string) string) @@
  {sql| SELECT id, name, start_date, end_date, format, is_active, reward_description, created_at, updated_at FROM seasons WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string string string string) (t2 bool (option string))) ->. Caqti_type.unit @@
  {sql| INSERT INTO seasons (name, start_date, end_date, format, is_active, reward_description) VALUES (?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string string string string) (t3 bool (option string) int)) ->. Caqti_type.unit @@
  {sql| UPDATE seasons SET name = ?, start_date = ?, end_date = ?, format = ?, is_active = ?, reward_description = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM seasons WHERE id = ? |sql}
