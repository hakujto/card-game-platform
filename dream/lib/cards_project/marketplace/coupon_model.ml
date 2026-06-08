(* Coupon model — record type + Caqti query definitions *)

type t = {
  id : int;
  code : string;
  discount_type : string;
  discount_value : float;
  min_order_value : float;
  max_uses : int option;
  uses_count : int;
  valid_from : string;
  valid_until : string;
  is_active : bool;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for Coupon ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Coupon record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11)) : t = {
  id = v0;
  code = v1;
  discount_type = v2;
  discount_value = v3;
  min_order_value = v4;
  max_uses = v5;
  uses_count = v6;
  valid_from = v7;
  valid_until = v8;
  is_active = v9;
  created_at = v10;
  updated_at = v11;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string string float) (t4 float (option int) int string) (t4 string bool string string)) @@
  {sql| SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string string float) (t4 float (option int) int string) (t4 string bool string string)) @@
  {sql| SELECT id, code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active, created_at, updated_at FROM coupons WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string string float float) (t4 (option int) int string string) bool) ->. Caqti_type.unit @@
  {sql| INSERT INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, uses_count, valid_from, valid_until, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 string string float float) (t4 (option int) int string string) (t2 bool int)) ->. Caqti_type.unit @@
  {sql| UPDATE coupons SET code = ?, discount_type = ?, discount_value = ?, min_order_value = ?, max_uses = ?, uses_count = ?, valid_from = ?, valid_until = ?, is_active = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM coupons WHERE id = ? |sql}
