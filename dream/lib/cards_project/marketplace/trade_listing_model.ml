(* TradeListing model — record type + Caqti query definitions *)

type t = {
  id : int;
  status : string;
  listing_type : string;
  asking_price : float option;
  auction_start_price : float option;
  auction_current_bid : float option;
  auction_end_time : string option;
  foil : bool;
  condition : string;
  quantity : int;
  description : string option;
  expires_at : string option;
  seller_id : int;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* Reverse relations for TradeListing:
 *   has_many bids -> TradeBid via listing_id
 *   has_one transaction -> TradeTransaction via listing_id
 *)

(* ── Caqti query definitions for TradeListing ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TradeListing record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)) : t = {
  id = v0;
  status = v1;
  listing_type = v2;
  asking_price = v3;
  auction_start_price = v4;
  auction_current_bid = v5;
  auction_end_time = v6;
  foil = v7;
  condition = v8;
  quantity = v9;
  description = v10;
  expires_at = v11;
  seller_id = v12;
  card_id = v13;
  created_at = v14;
  updated_at = v15;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int string string (option float)) (t4 (option float) (option float) (option string) bool) (t4 string int (option string) (option string)) (t4 int int string string)) @@
  {sql| SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int string string (option float)) (t4 (option float) (option float) (option string) bool) (t4 string int (option string) (option string)) (t4 int int string string)) @@
  {sql| SELECT id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 (t4 string string (option float) (option float)) (t4 (option float) (option string) bool string) (t4 int (option string) (option string) int) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO trade_listings (status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 (t4 string string (option float) (option float)) (t4 (option float) (option string) bool string) (t4 int (option string) (option string) int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE trade_listings SET status = ?, listing_type = ?, asking_price = ?, auction_start_price = ?, auction_current_bid = ?, auction_end_time = ?, foil = ?, condition = ?, quantity = ?, description = ?, expires_at = ?, seller_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM trade_listings WHERE id = ? |sql}
