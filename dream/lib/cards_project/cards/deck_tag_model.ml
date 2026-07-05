(* DeckTag model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  slug : string option;
  color : string option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for DeckTag:
 *   has_many deck_assignments -> DeckTagAssignment via tag_id
 *)

(* ── Caqti query definitions for DeckTag ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DeckTag record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5)) : t = {
  id = v0;
  name = v1;
  slug = v2;
  color = v3;
  created_at = v4;
  updated_at = v5;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string (option string) (option string)) (t2 string string)) @@
  {sql| SELECT id, name, slug, color, created_at, updated_at FROM deck_tags ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string (option string) (option string)) (t2 string string)) @@
  {sql| SELECT id, name, slug, color, created_at, updated_at FROM deck_tags WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 string (option string) (option string)) ->. Caqti_type.unit @@
  {sql| INSERT INTO deck_tags (name, slug, color) VALUES (?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 string (option string) (option string) int) ->. Caqti_type.unit @@
  {sql| UPDATE deck_tags SET name = ?, slug = ?, color = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM deck_tags WHERE id = ? |sql}
