(* ArticleTag model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  slug : string;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for ArticleTag:
 *   has_many article_assignments -> ArticleTagAssignment via tag_id
 *)

(* ── Caqti query definitions for ArticleTag ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the ArticleTag record *)
let row_to_t ((v0, v1, v2, v3), v4) : t = {
  id = v0;
  name = v1;
  slug = v2;
  created_at = v3;
  updated_at = v4;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string string string) string) @@
  {sql| SELECT id, name, slug, created_at, updated_at FROM article_tags ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string string string) string) @@
  {sql| SELECT id, name, slug, created_at, updated_at FROM article_tags WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 string string) ->. Caqti_type.unit @@
  {sql| INSERT INTO article_tags (name, slug) VALUES (?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 string string int) ->. Caqti_type.unit @@
  {sql| UPDATE article_tags SET name = ?, slug = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM article_tags WHERE id = ? |sql}
