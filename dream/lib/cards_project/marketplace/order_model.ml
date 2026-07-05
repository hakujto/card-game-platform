(* Order model — record type + Caqti query definitions *)

type t = {
  id : int;
  status : string;
  total : float;
  discount_applied : float;
  currency : string;
  payment_method : string option;
  payment_reference : string option;
  shipping_address : string option;
  tracking_number : string option;
  paid_at : string option;
  shipped_at : string option;
  player_id : int;
  coupon_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for Order:
 *   has_many items -> OrderItem via order_id
 *)

(* ── Caqti query definitions for Order ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Order record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14)) : t = {
  id = v0;
  status = v1;
  total = v2;
  discount_applied = v3;
  currency = v4;
  payment_method = v5;
  payment_reference = v6;
  shipping_address = v7;
  tracking_number = v8;
  paid_at = v9;
  shipped_at = v10;
  player_id = v11;
  coupon_id = v12;
  created_at = v13;
  updated_at = v14;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int string float float) (t4 string (option string) (option string) (option string)) (t4 (option string) (option string) (option string) int) (t3 (option int) string string)) @@
  {sql| SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id, created_at, updated_at FROM orders ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int string float float) (t4 string (option string) (option string) (option string)) (t4 (option string) (option string) (option string) int) (t3 (option int) string string)) @@
  {sql| SELECT id, status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id, created_at, updated_at FROM orders WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string float float string) (t4 (option string) (option string) (option string) (option string)) (t4 (option string) (option string) int (option int))) ->. Caqti_type.unit @@
  {sql| INSERT INTO orders (status, total, discount_applied, currency, payment_method, payment_reference, shipping_address, tracking_number, paid_at, shipped_at, player_id, coupon_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 float float string (option string)) (t4 (option string) (option string) (option string) (option string)) (t3 int (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE orders SET total = ?, discount_applied = ?, currency = ?, payment_method = ?, payment_reference = ?, shipping_address = ?, tracking_number = ?, shipped_at = ?, player_id = ?, coupon_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM orders WHERE id = ? |sql}


(* ── Audit log for Order ── *)
type audit_log_t = {
  id : int;
  record_id : int;
  field : string;
  old_value : string option;
  new_value : string option;
  changed_by_id : int option;
  changed_at : string;
} [@@deriving yojson]

let audit_log_insert_q =
  Caqti_type.(t2 (t4 int string (option string) (option string)) (t2 (option int) string)) ->.
  Caqti_type.unit @@
  {sql| INSERT INTO order_audit_log (record_id, field, old_value, new_value, changed_by_id, changed_at) VALUES (?, ?, ?, ?, ?, ?) |sql}