(* CardAbility model — record type + Caqti query definitions *)

type t = {
  id : int;
  ability_type : string;
  keyword : string option;
  ability_text : string;
  timing : string option;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for CardAbility ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the CardAbility record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7)) : t = {
  id = v0;
  ability_type = v1;
  keyword = v2;
  ability_text = v3;
  timing = v4;
  card_id = v5;
  created_at = v6;
  updated_at = v7;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string (option string) string) (t4 (option string) int string string)) @@
  {sql| SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string (option string) string) (t4 (option string) int string string)) @@
  {sql| SELECT id, ability_type, keyword, ability_text, timing, card_id, created_at, updated_at FROM card_abilities WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string (option string) string (option string)) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO card_abilities (ability_type, keyword, ability_text, timing, card_id) VALUES (?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string (option string) string (option string)) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE card_abilities SET ability_type = ?, keyword = ?, ability_text = ?, timing = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM card_abilities WHERE id = ? |sql}
