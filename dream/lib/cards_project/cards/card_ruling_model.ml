(* CardRuling model — record type + Caqti query definitions *)

type t = {
  id : int;
  ruling_text : string;
  published_at : string;
  source : string;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for CardRuling ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the CardRuling record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6)) : t = {
  id = v0;
  ruling_text = v1;
  published_at = v2;
  source = v3;
  card_id = v4;
  created_at = v5;
  updated_at = v6;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string string string) (t3 int string string)) @@
  {sql| SELECT id, ruling_text, published_at, source, card_id, created_at, updated_at FROM card_rulings ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string string string) (t3 int string string)) @@
  {sql| SELECT id, ruling_text, published_at, source, card_id, created_at, updated_at FROM card_rulings WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 string string string int) ->. Caqti_type.unit @@
  {sql| INSERT INTO card_rulings (ruling_text, published_at, source, card_id) VALUES (?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string string string int) int) ->. Caqti_type.unit @@
  {sql| UPDATE card_rulings SET ruling_text = ?, published_at = ?, source = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM card_rulings WHERE id = ? |sql}
