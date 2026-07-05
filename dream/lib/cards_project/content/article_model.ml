(* Article model — record type + Caqti query definitions *)

type t = {
  id : int;
  title : string;
  slug : string;
  body : string;
  excerpt : string option;
  cover_image_url : string option;
  status : string;
  article_type : string;
  language : string;
  view_count : int;
  likes_count : int;
  total_views_alltime : int;
  is_featured : bool;
  published_at : string option;
  author_id : int;
  featured_deck_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Article:
 *   has_many tag_assignments -> ArticleTagAssignment via article_id
 *   has_many comments -> ArticleComment via article_id
 *)

(* ── Caqti query definitions for Article ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Article record *)
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), (v16, v17)) : t = {
  id = v0;
  title = v1;
  slug = v2;
  body = v3;
  excerpt = v4;
  cover_image_url = v5;
  status = v6;
  article_type = v7;
  language = v8;
  view_count = v9;
  likes_count = v10;
  total_views_alltime = v11;
  is_featured = v12;
  published_at = v13;
  author_id = v14;
  featured_deck_id = v15;
  created_at = v16;
  updated_at = v17;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string string string) (t4 (option string) (option string) string string) (t4 string int int int) (t4 bool (option string) int (option int))) (t2 string string)) @@
  {sql| SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string string string) (t4 (option string) (option string) string string) (t4 string int int int) (t4 bool (option string) int (option int))) (t2 string string)) @@
  {sql| SELECT id, title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id, created_at, updated_at FROM articles WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 (t4 string string string (option string)) (t4 (option string) string string string) (t4 int int int bool) (t3 (option string) int (option int))) ->. Caqti_type.unit @@
  {sql| INSERT INTO articles (title, slug, body, excerpt, cover_image_url, status, article_type, language, view_count, likes_count, total_views_alltime, is_featured, published_at, author_id, featured_deck_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 (t4 string string string (option string)) (t4 (option string) string string int) (t4 bool (option string) int (option int)) int) ->. Caqti_type.unit @@
  {sql| UPDATE articles SET title = ?, slug = ?, body = ?, excerpt = ?, cover_image_url = ?, article_type = ?, language = ?, total_views_alltime = ?, is_featured = ?, published_at = ?, author_id = ?, featured_deck_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM articles WHERE id = ? |sql}
