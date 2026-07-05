(* TradeListing model — record type + Caqti query definitions *)

type t = {
  id : int;
  public_id : string;
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
let row_to_t (((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)), v16) : t = {
  id = v0;
  public_id = v1;
  status = v2;
  listing_type = v3;
  asking_price = v4;
  auction_start_price = v5;
  auction_current_bid = v6;
  auction_end_time = v7;
  foil = v8;
  condition = v9;
  quantity = v10;
  description = v11;
  expires_at = v12;
  seller_id = v13;
  card_id = v14;
  created_at = v15;
  updated_at = v16;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 (t4 int string string string) (t4 (option float) (option float) (option float) (option string)) (t4 bool string int (option string)) (t4 (option string) int int string)) string) @@
  {sql| SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 (t4 int string string string) (t4 (option float) (option float) (option float) (option string)) (t4 bool string int (option string)) (t4 (option string) int int string)) string) @@
  {sql| SELECT id, public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id, created_at, updated_at FROM trade_listings WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 (t4 string string string (option float)) (t4 (option float) (option float) (option string) bool) (t4 string int (option string) (option string)) (t2 int int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO trade_listings (public_id, status, listing_type, asking_price, auction_start_price, auction_current_bid, auction_end_time, foil, condition, quantity, description, expires_at, seller_id, card_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 (t4 string string (option float) (option float)) (t4 (option float) (option string) bool string) (t4 int (option string) (option string) int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE trade_listings SET public_id = ?, listing_type = ?, asking_price = ?, auction_start_price = ?, auction_current_bid = ?, auction_end_time = ?, foil = ?, condition = ?, quantity = ?, description = ?, expires_at = ?, seller_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM trade_listings WHERE id = ? |sql}
