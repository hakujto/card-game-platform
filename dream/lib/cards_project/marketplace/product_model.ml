(* Product model — record type + Caqti query definitions *)

type t = {
  id : int;
  name : string;
  product_type : string;
  price : float;
  stock : int;
  active : bool;
  discount_percent : int;
  description : string option;
  image_url : string option;
  featured : bool;
  card_id : int option;
  card_set_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for Product ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Product record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13)) : t = {
  id = v0;
  name = v1;
  product_type = v2;
  price = v3;
  stock = v4;
  active = v5;
  discount_percent = v6;
  description = v7;
  image_url = v8;
  featured = v9;
  card_id = v10;
  card_set_id = v11;
  created_at = v12;
  updated_at = v13;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int string string float) (t4 int bool int (option string)) (t4 (option string) bool (option int) (option int)) (t2 string string)) @@
  {sql| SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int string string float) (t4 int bool int (option string)) (t4 (option string) bool (option int) (option int)) (t2 string string)) @@
  {sql| SELECT id, name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id, created_at, updated_at FROM products WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string string float int) (t4 bool int (option string) (option string)) (t3 bool (option int) (option int))) ->. Caqti_type.unit @@
  {sql| INSERT INTO products (name, product_type, price, stock, active, discount_percent, description, image_url, featured, card_id, card_set_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 string string float int) (t4 bool int (option string) (option string)) (t4 bool (option int) (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE products SET name = ?, product_type = ?, price = ?, stock = ?, active = ?, discount_percent = ?, description = ?, image_url = ?, featured = ?, card_id = ?, card_set_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM products WHERE id = ? |sql}
