(* OrderItem model — record type + Caqti query definitions *)

type t = {
  id : int;
  quantity : int;
  price_at_purchase : float;
  foil : bool;
  order_id : int;
  product_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for OrderItem ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the OrderItem record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7)) : t = {
  id = v0;
  quantity = v1;
  price_at_purchase = v2;
  foil = v3;
  order_id = v4;
  product_id = v5;
  created_at = v6;
  updated_at = v7;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int float bool) (t4 int int string string)) @@
  {sql| SELECT id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at FROM order_items ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int float bool) (t4 int int string string)) @@
  {sql| SELECT id, quantity, price_at_purchase, foil, order_id, product_id, created_at, updated_at FROM order_items WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 int float bool int) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO order_items (quantity, price_at_purchase, foil, order_id, product_id) VALUES (?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 int float bool int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE order_items SET quantity = ?, price_at_purchase = ?, foil = ?, order_id = ?, product_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM order_items WHERE id = ? |sql}
