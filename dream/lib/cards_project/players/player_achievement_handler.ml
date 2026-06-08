(* Dream handlers for PlayerAchievement *)
open Lwt.Syntax

let apply_projection_player_achievement (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "earned_at" then ("earned_at", v) else (k, v)) fields in
    `Assoc fields
  | other -> other

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

let validate_player_achievement (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "progress") with Some v -> v >= 0. | None -> true)) then errors := "Achievement progress must not be negative" :: !errors;
  if not ((not ((json_bool_opt j "is_completed") = Some true) || ((match (json_float_opt j "progress") with Some v -> v > 0. | None -> true)))) then errors := "Completed achievement must have progress greater than zero" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let earned_at = match member "earned_at" j with `String s -> s | _ -> "" in
  let progress = match member "progress" j with `Int i -> i | _ -> 0 in
  let is_completed = match member "is_completed" j with `Bool b -> b | _ -> false in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  let achievement_id = match member "achievement_id" j with `Int i -> i | _ -> 0 in
  ((earned_at, progress, is_completed, player_id), achievement_id)

let handler_player_achievement (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/player_achievements - list all *)
  | `GET, ["api"; "player_achievements"] ->
    let* rows = Db.collect_list Player_achievement_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Player_achievement_model.to_yojson (Player_achievement_model.row_to_t r) in
         apply_projection_player_achievement j) items) in
       respond_json 200 json)

  (* GET /api/player_achievements/:id - get one *)
  | `GET, ["api"; "player_achievements"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Player_achievement_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Player_achievement_model.to_yojson (Player_achievement_model.row_to_t r) in
          respond_json 200 (apply_projection_player_achievement j)))

  (* PATCH /api/player-achievements/{id}/progress - behavior increment_progress *)
  | `PATCH, ["api"; "player_achievements"; id_str; "_id/progress"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior increment_progress *)
       respond_json 204 (`Null))

  (* POST /api/player-achievements/{id}/complete - behavior complete *)
  | `POST, ["api"; "player_achievements"; id_str; "_id/complete"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior complete *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
