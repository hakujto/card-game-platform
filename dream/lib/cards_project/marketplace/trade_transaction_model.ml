(* TradeTransaction model — record type + Caqti query definitions *)

type t = {
  id : int;
  final_price : float;
  platform_fee : float;
  status : string;
  completed_at : string option;
  listing_id : int;
  buyer_id : int;
  seller_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for TradeTransaction:
 *   has_one dispute -> TradeDispute via transaction_id
 *)

(* ── Caqti query definitions for TradeTransaction ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TradeTransaction record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9)) : t = {
  id = v0;
  final_price = v1;
  platform_fee = v2;
  status = v3;
  completed_at = v4;
  listing_id = v5;
  buyer_id = v6;
  seller_id = v7;
  created_at = v8;
  updated_at = v9;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int float float string) (t4 (option string) int int int) (t2 string string)) @@
  {sql| SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at FROM trade_transactions ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int float float string) (t4 (option string) int int int) (t2 string string)) @@
  {sql| SELECT id, final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id, created_at, updated_at FROM trade_transactions WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 float float string (option string)) (t3 int int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO trade_transactions (final_price, platform_fee, status, completed_at, listing_id, buyer_id, seller_id) VALUES (?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 float float string (option string)) (t4 int int int int)) ->. Caqti_type.unit @@
  {sql| UPDATE trade_transactions SET final_price = ?, platform_fee = ?, status = ?, completed_at = ?, listing_id = ?, buyer_id = ?, seller_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM trade_transactions WHERE id = ? |sql}
