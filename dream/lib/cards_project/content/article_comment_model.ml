(* ArticleComment model — record type + Caqti query definitions *)

type t = {
  id : int;
  body : string;
  is_hidden : bool;
  article_id : int;
  author_id : int;
  parent_comment_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for ArticleComment ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the ArticleComment record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7)) : t = {
  id = v0;
  body = v1;
  is_hidden = v2;
  article_id = v3;
  author_id = v4;
  parent_comment_id = v5;
  created_at = v6;
  updated_at = v7;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string bool int) (t4 int (option int) string string)) @@
  {sql| SELECT id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at FROM article_comments ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string bool int) (t4 int (option int) string string)) @@
  {sql| SELECT id, body, is_hidden, article_id, author_id, parent_comment_id, created_at, updated_at FROM article_comments WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string bool int int) (option int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO article_comments (body, is_hidden, article_id, author_id, parent_comment_id) VALUES (?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string bool int int) (t2 (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE article_comments SET body = ?, is_hidden = ?, article_id = ?, author_id = ?, parent_comment_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM article_comments WHERE id = ? |sql}
