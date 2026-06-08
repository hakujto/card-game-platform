(* Stream model — record type + Caqti query definitions *)

type t = {
  id : int;
  title : string;
  stream_url : string;
  status : string;
  platform : string;
  language : string;
  is_official : bool;
  viewer_count_peak : int;
  scheduled_start : string;
  actual_start : string option;
  ended_at : string option;
  vod_url : string option;
  tournament_id : int option;
  streamer_id : int;
  created_at : string;
  updated_at : string;
} [@@deriving yojson]

(* ── Caqti query definitions for Stream ── *)
open Caqti_request.Infix

(* Convert nested-tuple Caqti row into the Stream record *)
let row_to_t ((v0, v1, v2, v3), (v4, v5, v6, v7), (v8, v9, v10, v11), (v12, v13, v14, v15)) : t = {
  id = v0;
  title = v1;
  stream_url = v2;
  status = v3;
  platform = v4;
  language = v5;
  is_official = v6;
  viewer_count_peak = v7;
  scheduled_start = v8;
  actual_start = v9;
  ended_at = v10;
  vod_url = v11;
  tournament_id = v12;
  streamer_id = v13;
  created_at = v14;
  updated_at = v15;
}

let get_all_q =
  Caqti_type.unit ->* Caqti_type.(t4 (t4 int string string string) (t4 string string bool int) (t4 string (option string) (option string) (option string)) (t4 (option int) int string string)) @@
  {sql| SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams ORDER BY id |sql}

let get_by_id_q =
  Caqti_type.int ->? Caqti_type.(t4 (t4 int string string string) (t4 string string bool int) (t4 string (option string) (option string) (option string)) (t4 (option int) int string string)) @@
  {sql| SELECT id, title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id, created_at, updated_at FROM streams WHERE id = ? |sql}

let insert_q =
  Caqti_type.(t4 (t4 string string string string) (t4 string bool int string) (t4 (option string) (option string) (option string) (option int)) int) ->. Caqti_type.unit @@
  {sql| INSERT INTO streams (title, stream_url, status, platform, language, is_official, viewer_count_peak, scheduled_start, actual_start, ended_at, vod_url, tournament_id, streamer_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) |sql}

let last_id_q =
  Caqti_type.unit ->! Caqti_type.int @@
  {sql| SELECT last_insert_rowid() |sql}

let update_q =
  Caqti_type.(t4 (t4 string string string string) (t4 string bool int string) (t4 (option string) (option string) (option string) (option int)) (t2 int int)) ->. Caqti_type.unit @@
  {sql| UPDATE streams SET title = ?, stream_url = ?, status = ?, platform = ?, language = ?, is_official = ?, viewer_count_peak = ?, scheduled_start = ?, actual_start = ?, ended_at = ?, vod_url = ?, tournament_id = ?, streamer_id = ?, updated_at = datetime('now') WHERE id = ? |sql}

let delete_q =
  Caqti_type.int ->. Caqti_type.unit @@
  {sql| DELETE FROM streams WHERE id = ? |sql}
