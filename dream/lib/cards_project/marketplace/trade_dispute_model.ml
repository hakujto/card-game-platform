(* TradeDispute model — record type + Caqti query definitions *)

type t = {
  id : int;
  status : string;
  reason : string;
  description : string;
  resolution : string option;
  opened_at : string;
  resolved_at : string option;
  transaction_id : int;
  opened_by_id : int;
  resolved_by_id : int option;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for TradeDispute ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the TradeDispute record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11)) : t = {
  id = v0;
  status = v1;
  reason = v2;
  description = v3;
  resolution = v4;
  opened_at = v5;
  resolved_at = v6;
  transaction_id = v7;
  opened_by_id = v8;
  resolved_by_id = v9;
  created_at = v10;
  updated_at = v11;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t3 (t4 int string string string) (t4 (option string) string (option string) int) (t4 int (option int) string string)) @@
  {sql| SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at FROM trade_disputes ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t3 (t4 int string string string) (t4 (option string) string (option string) int) (t4 int (option int) string string)) @@
  {sql| SELECT id, status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id, created_at, updated_at FROM trade_disputes WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 (t4 string string string (option string)) (t4 string (option string) int int) (option int)) ->. Caqti_type.unit @@
  {sql| INSERT INTO trade_disputes (status, reason, description, resolution, opened_at, resolved_at, transaction_id, opened_by_id, resolved_by_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t3 (t4 string string string (option string)) (t4 string (option string) int int) (t2 (option int) int)) ->. Caqti_type.unit @@
  {sql| UPDATE trade_disputes SET status = ?, reason = ?, description = ?, resolution = ?, opened_at = ?, resolved_at = ?, transaction_id = ?, opened_by_id = ?, resolved_by_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM trade_disputes WHERE id = ? |sql}
