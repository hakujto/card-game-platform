(* Dream handlers for PlayerSeasonStats *)
open Lwt.Syntax

(* JSON field helpers *)
let json_string_opt j key =
  match Yojson.Safe.Util.member key j with
  | `String s -> Some s
  | `Null | `Assoc [] -> None
  | _ -> None

let json_float_opt j key =
  match Yojson.Safe.Util.member key j with
  | `Float f -> Some f
  | `Int i -> Some (float_of_int i)
  | `String s -> (try Some (float_of_string s) with _ -> None)
  | _ -> None

let json_present j key =
  match Yojson.Safe.Util.member key j with
  | `Null | `Assoc [] -> false
  | _ -> true

let json_bool_opt j key =
  match Yojson.Safe.Util.member key j with
  | `Bool b -> Some b
  | _ -> None

let validate_player_season_stats (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "wins") with Some v -> v >= 0. | None -> true)) then errors := "Season wins must not be negative" :: !errors;
  if not ((match (json_float_opt j "losses") with Some v -> v >= 0. | None -> true)) then errors := "Season losses must not be negative" :: !errors;
  if not ((match (json_float_opt j "tournament_wins") with Some v -> v >= 0. | None -> true)) then errors := "Season tournament wins must not be negative" :: !errors;
  if not ((match (json_float_opt j "season_points") with Some v -> v >= 0. | None -> true)) then errors := "Season points must not be negative" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let wins = match member "wins" j with `Int i -> i | _ -> 0 in
  let losses = match member "losses" j with `Int i -> i | _ -> 0 in
  let draws = match member "draws" j with `Int i -> i | _ -> 0 in
  let tournament_wins = match member "tournament_wins" j with `Int i -> i | _ -> 0 in
  let highest_rank = match member "highest_rank" j with `String s -> Some s | _ -> None in
  let season_points = match member "season_points" j with `Int i -> i | _ -> 0 in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  let season_id = match member "season_id" j with `Int i -> i | _ -> 0 in
  ((wins, losses, draws, tournament_wins), (highest_rank, season_points, player_id, season_id))

let handler_player_season_stats (db : (module Caqti_lwt.CONNECTION)) req =
  let respond_json status body =
    Dream.respond ~status:(Dream.int_to_status status)
      ~headers:[("Content-Type", "application/json")]
      (Yojson.Safe.to_string body)
  in
  let module Db = (val db) in
  let target_path = match String.index_opt (Dream.target req) '?' with
    | Some i -> String.sub (Dream.target req) 0 i
    | None -> Dream.target req
  in
  let path_segments = target_path |> String.split_on_char '/' |> List.filter (fun s -> s <> "") in
  match Dream.method_ req, path_segments with

  (* GET /api/player_season_statses - list all *)
  | `GET, ["api"; "player_season_statses"] ->
    let* rows = Db.collect_list Player_season_stats_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Player_season_stats_model.to_yojson (Player_season_stats_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* GET /api/player_season_statses/:id - get one *)
  | `GET, ["api"; "player_season_statses"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Player_season_stats_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Player_season_stats_model.to_yojson (Player_season_stats_model.row_to_t r) in
          respond_json 200 (j)))

  (* GET /api/player-season-stats/{id}/win-rate - behavior win_rate *)
  | `GET, ["api"; "player_season_statses"; id_str; "_id/win-rate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior win_rate *)
       respond_json 204 (`Null))

  (* PATCH /api/player-season-stats/{id}/points - behavior add_points *)
  | `PATCH, ["api"; "player_season_statses"; id_str; "_id/points"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior add_points *)
       respond_json 204 (`Null))

  (* POST /api/player-season-stats/{id}/tournament-win - behavior record_tournament_win *)
  | `POST, ["api"; "player_season_statses"; id_str; "_id/tournament-win"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior record_tournament_win *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
