(* ArticleTagAssignment model — record type + Caqti query definitions *)

type t = {
  id : int;
  article_id : int;
  tag_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for ArticleTagAssignment ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the ArticleTagAssignment record *)
let row_to_t ((v0, v1, v2, v3), v4) : t = {
  id = v0;
  article_id = v1;
  tag_id = v2;
  created_at = v3;
  updated_at = v4;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int int string) string) @@
  {sql| SELECT id, article_id, tag_id, created_at, updated_at FROM article_tag_assignments ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int int string) string) @@
  {sql| SELECT id, article_id, tag_id, created_at, updated_at FROM article_tag_assignments WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO article_tag_assignments (article_id, tag_id) VALUES (?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 int int int) ->. Caqti_type.unit @@
  {sql| UPDATE article_tag_assignments SET article_id = ?, tag_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM article_tag_assignments WHERE id = ? |sql}
