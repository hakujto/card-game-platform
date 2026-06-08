(* CraftingIngredient model — record type + Caqti query definitions *)

type t = {
  id : int;
  quantity : int;
  recipe_id : int;
  card_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for CraftingIngredient ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the CraftingIngredient record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5)) : t = {
  id = v0;
  quantity = v1;
  recipe_id = v2;
  card_id = v3;
  created_at = v4;
  updated_at = v5;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int int int int) (t2 string string)) @@
  {sql| SELECT id, quantity, recipe_id, card_id, created_at, updated_at FROM crafting_ingredients ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int int int int) (t2 string string)) @@
  {sql| SELECT id, quantity, recipe_id, card_id, created_at, updated_at FROM crafting_ingredients WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t3 int int int) ->. Caqti_type.unit @@
  {sql| INSERT INTO crafting_ingredients (quantity, recipe_id, card_id) VALUES (?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 int int int int) ->. Caqti_type.unit @@
  {sql| UPDATE crafting_ingredients SET quantity = ?, recipe_id = ?, card_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM crafting_ingredients WHERE id = ? |sql}
