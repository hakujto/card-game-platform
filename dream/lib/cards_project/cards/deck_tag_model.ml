(* DeckTag model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  color : string option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for DeckTag ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the DeckTag record *)
let row_to_t ((v0, v1, v2, v3), v4) : t = {
  id = v0;
  name = v1;
  color = v2;
  created_at = v3;
  updated_at = v4;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string (option string) string) string) @@
  {sql| SELECT id, name, color, created_at, updated_at FROM deck_tags ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string (option string) string) string) @@
  {sql| SELECT id, name, color, created_at, updated_at FROM deck_tags WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 string (option string)) ->. Caqti_type.unit @@
  {sql| INSERT INTO deck_tags (name, color) VALUES (?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 string (option string) int) ->. Caqti_type.unit @@
  {sql| UPDATE deck_tags SET name = ?, color = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM deck_tags WHERE id = ? |sql}
