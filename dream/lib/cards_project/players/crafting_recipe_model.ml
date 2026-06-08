(* CraftingRecipe model — record type + Caqti query definitions *)

type t = {
  id : int;
  dust_cost : int;
  is_available : bool;
  result_card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for CraftingRecipe ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the CraftingRecipe record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5)) : t = {
  id = v0;
  dust_cost = v1;
  is_available = v2;
  result_card_id = v3;
  created_at = v4;
  updated_at = v5;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int bool int) (t2 string string)) @@
  {sql| SELECT id, dust_cost, is_available, result_card_id, created_at, updated_at FROM crafting_recipes ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int bool int) (t2 string string)) @@
  {sql| SELECT id, dust_cost, is_available, result_card_id, created_at, updated_at FROM crafting_recipes WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 int bool int) ->. Caqti_type.unit @@
  {sql| INSERT INTO crafting_recipes (dust_cost, is_available, result_card_id) VALUES (?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 int bool int int) ->. Caqti_type.unit @@
  {sql| UPDATE crafting_recipes SET dust_cost = ?, is_available = ?, result_card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM crafting_recipes WHERE id = ? |sql}
