(* Dream handlers for Game *)
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

let validate_game (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "game_number") with Some v -> v >= 1. && v <= 3. | None -> true)) then errors := "Game number must be between 1 and 3 (best-of-3)" :: !errors;
  if not ((not ((json_present j "turns_played")) || ((match (json_float_opt j "turns_played") with Some v -> v > 0. | None -> true)))) then errors := "Turns played must be greater than zero" :: !errors;
  if not ((not ((json_present j "duration_seconds")) || ((match (json_float_opt j "duration_seconds") with Some v -> v > 0. | None -> true)))) then errors := "Game duration must be greater than zero" :: !errors;
  if not ((not ((json_string_opt j "winner_side") = Some "Draw") || ((not (json_present j "winner_id"))))) then errors := "A draw cannot have a winner" :: !errors;
  if not ((not (((json_present j "winner_side") && (json_string_opt j "winner_side") <> Some "Draw")) || ((json_present j "winner_id")))) then errors := "A decisive game must have a winner player set" :: !errors;
  (match json_float_opt j "game_number" with
   | Some v when v < 1. -> errors := "game_number: must be >= 1" :: !errors
   | _ -> ());
  (match json_float_opt j "game_number" with
   | Some v when v > 3. -> errors := "game_number: must be <= 3" :: !errors
   | _ -> ());
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let game_number = match member "game_number" j with `Int i -> i | _ -> 0 in
  let winner_side = match member "winner_side" j with `String s -> Some s | _ -> None in
  let complexity_score = match member "complexity_score" j with `Float f -> Some f | `Int i -> Some (float_of_int i) | _ -> None in
  let turns_played = match member "turns_played" j with `Int i -> Some i | _ -> None in
  let duration_seconds = match member "duration_seconds" j with `Int i -> Some i | _ -> None in
  let ended_by = match member "ended_by" j with `String s -> Some s | _ -> None in
  let replay_url = match member "replay_url" j with `String s -> Some s | _ -> None in
  let match_id = match member "match_id" j with `Int i -> i | _ -> 0 in
  let winner_id = match member "winner_id" j with `Int i -> Some i | _ -> None in
  ((game_number, winner_side, complexity_score, turns_played), (duration_seconds, ended_by, replay_url, match_id), winner_id)

let handler_game (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/games - list all *)
  | `GET, ["api"; "games"] ->
    let* rows = Db.collect_list Game_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Game_model.to_yojson (Game_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/games - create *)
  | `POST, ["api"; "games"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_game j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Game_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Game_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Game_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Game_model.to_yojson (Game_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/games/:id - get one *)
  | `GET, ["api"; "games"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Game_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Game_model.to_yojson (Game_model.row_to_t r) in
          respond_json 200 (j)))

  (* POST /api/games/{id}/winner - behavior record_winner *)
  | `POST, ["api"; "games"; id_str; "_id/winner"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior record_winner *)
       respond_json 204 (`Null))

  (* GET /api/games/{id}/duration - behavior duration_minutes *)
  | `GET, ["api"; "games"; id_str; "_id/duration"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior duration_minutes *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
