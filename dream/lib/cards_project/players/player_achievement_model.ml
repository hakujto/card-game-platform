(* PlayerAchievement model — record type + Caqti query definitions *)

type t = {
  id : int;
  earned_at : string;
  progress : int;
  is_completed : bool;
  player_id : int;
  achievement_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for PlayerAchievement ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the PlayerAchievement record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7)) : t = {
  id = v0;
  earned_at = v1;
  progress = v2;
  is_completed = v3;
  player_id = v4;
  achievement_id = v5;
  created_at = v6;
  updated_at = v7;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t2 (t4 int string int bool) (t4 int int string string)) @@
  {sql| SELECT id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at FROM player_achievements ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t2 (t4 int string int bool) (t4 int int string string)) @@
  {sql| SELECT id, earned_at, progress, is_completed, player_id, achievement_id, created_at, updated_at FROM player_achievements WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t2 (t4 string int bool int) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO player_achievements (earned_at, progress, is_completed, player_id, achievement_id) VALUES (?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t2 (t4 string int bool int) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE player_achievements SET earned_at = ?, progress = ?, is_completed = ?, player_id = ?, achievement_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM player_achievements WHERE id = ? |sql}
