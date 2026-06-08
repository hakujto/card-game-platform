(* TradeBid model — record type + Caqti query definitions *)

type t = {
  id : int;
  amount : float;
  placed_at : string;
  is_winning : bool;
  listing_id : int;
  bidder_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for TradeBid ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TradeBid record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7)) : t = {
  id = v0;
  amount = v1;
  placed_at = v2;
  is_winning = v3;
  listing_id = v4;
  bidder_id = v5;
  created_at = v6;
  updated_at = v7;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int float string bool) (t4 int int string string)) @@
  {sql| SELECT id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at FROM trade_bids ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int float string bool) (t4 int int string string)) @@
  {sql| SELECT id, amount, placed_at, is_winning, listing_id, bidder_id, created_at, updated_at FROM trade_bids WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 float string bool int) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO trade_bids (amount, placed_at, is_winning, listing_id, bidder_id) VALUES (?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 float string bool int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE trade_bids SET amount = ?, placed_at = ?, is_winning = ?, listing_id = ?, bidder_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM trade_bids WHERE id = ? |sql}
