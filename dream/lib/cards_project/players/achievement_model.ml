(* Achievement model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  description : string;
  icon_url : string option;
  points : int;
  rarity : string;
  is_hidden : bool;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Achievement:
 *   many_to_many players -> Player through player_achievements
 *   has_many player_records -> PlayerAchievement via achievement_id
 *)

(* ── Caqti query definitions for Achievement ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Achievement record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), v8) : t = {
  id = v0;
  name = v1;
  description = v2;
  icon_url = v3;
  points = v4;
  rarity = v5;
  is_hidden = v6;
  created_at = v7;
  updated_at = v8;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string string (option string)) (t4 int string bool string) string) @@
  {sql| SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string string (option string)) (t4 int string bool string) string) @@
  {sql| SELECT id, name, description, icon_url, points, rarity, is_hidden, created_at, updated_at FROM achievements WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string string (option string) int) (t2 string bool)) ->. Caqti_type.unit @@
  {sql| INSERT INTO achievements (name, description, icon_url, points, rarity, is_hidden) VALUES (?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string string (option string) int) (t3 string bool int)) ->. Caqti_type.unit @@
  {sql| UPDATE achievements SET name = ?, description = ?, icon_url = ?, points = ?, rarity = ?, is_hidden = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM achievements WHERE id = ? |sql}
