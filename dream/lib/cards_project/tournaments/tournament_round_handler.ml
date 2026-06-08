(* Dream handlers for TournamentRound *)
open Lwt.Syntax

let apply_projection_tournament_round (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "started_at" then ("started_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "ended_at" then ("ended_at", v) else (k, v)) fields in
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

let validate_tournament_round (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "round_number") with Some v -> v > 0. | None -> true)) then errors := "Round number must be greater than zero" :: !errors;
  if not ((match (json_float_opt j "time_limit_minutes") with Some v -> v > 0. | None -> true)) then errors := "Round time limit must be greater than zero" :: !errors;
  if not ((not ((json_present j "ended_at")) || ((match (json_float_opt j "ended_at") with Some v -> v > (Option.value (json_float_opt j "started_at") ~default:0.) | None -> true)))) then errors := "Round end time must be after start time" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "Completed") || ((json_present j "started_at")))) then errors := "Completed round must have a start time" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let round_number = match member "round_number" j with `Int i -> i | _ -> 0 in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let started_at = match member "started_at" j with `String s -> Some s | _ -> None in
  let ended_at = match member "ended_at" j with `String s -> Some s | _ -> None in
  let time_limit_minutes = match member "time_limit_minutes" j with `Int i -> i | _ -> 0 in
  let tournament_id = match member "tournament_id" j with `Int i -> i | _ -> 0 in
  ((round_number, status, started_at, ended_at), (time_limit_minutes, tournament_id))

let handler_tournament_round (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/tournament_rounds - list all *)
  | `GET, ["api"; "tournament_rounds"] ->
    let* rows = Db.collect_list Tournament_round_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Tournament_round_model.to_yojson (Tournament_round_model.row_to_t r) in
         apply_projection_tournament_round j) items) in
       respond_json 200 json)

  (* POST /api/tournament_rounds - create *)
  | `POST, ["api"; "tournament_rounds"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_tournament_round j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Tournament_round_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Tournament_round_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Tournament_round_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Tournament_round_model.to_yojson (Tournament_round_model.row_to_t r) in
                respond_json 201 (apply_projection_tournament_round j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/tournament_rounds/:id - get one *)
  | `GET, ["api"; "tournament_rounds"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_round_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Tournament_round_model.to_yojson (Tournament_round_model.row_to_t r) in
          respond_json 200 (apply_projection_tournament_round j)))

  (* POST /api/rounds/{id}/start - behavior start *)
  | `POST, ["api"; "tournament_rounds"; id_str; "_id/start"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior start *)
       respond_json 204 (`Null))

  (* POST /api/rounds/{id}/complete - behavior complete *)
  | `POST, ["api"; "tournament_rounds"; id_str; "_id/complete"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior complete *)
       respond_json 204 (`Null))

  (* POST /api/rounds/{id}/pairings - behavior generate_pairings *)
  | `POST, ["api"; "tournament_rounds"; id_str; "_id/pairings"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior generate_pairings *)
       respond_json 204 (`Null))

  (* GET /api/rounds/{id}/time-expired - behavior is_time_expired *)
  | `GET, ["api"; "tournament_rounds"; id_str; "_id/time-expired"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_time_expired *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
