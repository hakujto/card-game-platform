(* CardPriceHistory model — record type + Caqti query definitions *)

type t = {
  id : int;
  price_date : string;
  avg_price : float;
  min_price : float;
  max_price : float;
  volume : int;
  foil : bool;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for CardPriceHistory ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the CardPriceHistory record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9)) : t = {
  id = v0;
  price_date = v1;
  avg_price = v2;
  min_price = v3;
  max_price = v4;
  volume = v5;
  foil = v6;
  card_id = v7;
  created_at = v8;
  updated_at = v9;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string float float) (t4 float int bool int) (t2 string string)) @@
  {sql| SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at FROM card_price_histories ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string float float) (t4 float int bool int) (t2 string string)) @@
  {sql| SELECT id, price_date, avg_price, min_price, max_price, volume, foil, card_id, created_at, updated_at FROM card_price_histories WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string float float float) (t3 int bool int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO card_price_histories (price_date, avg_price, min_price, max_price, volume, foil, card_id) VALUES (?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string float float float) (t4 int bool int int)) ->. Caqti_type.unit @@
  {sql| UPDATE card_price_histories SET price_date = ?, avg_price = ?, min_price = ?, max_price = ?, volume = ?, foil = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM card_price_histories WHERE id = ? |sql}
