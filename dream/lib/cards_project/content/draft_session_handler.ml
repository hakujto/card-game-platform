(* Dream handlers for DraftSession *)
open Lwt.Syntax

let apply_projection_draft_session (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "completed_at" then ("completed_at", v) else (k, v)) fields in
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

let validate_draft_session (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "seats") with Some v -> v >= 2. && v <= 16. | None -> true)) then errors := "Draft session must have between 2 and 16 seats" :: !errors;
  if not ((match (json_float_opt j "time_per_pick_seconds") with Some v -> v > 0. | None -> true)) then errors := "Time per pick must be greater than zero" :: !errors;
  if not ((not ((json_present j "completed_at")) || ((json_string_opt j "status") = Some "Completed"))) then errors := "completed_at can only be set when draft status is Completed" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let draft_type = match member "draft_type" j with `String s -> s | _ -> "" in
  let seats = match member "seats" j with `Int i -> i | _ -> 0 in
  let time_per_pick_seconds = match member "time_per_pick_seconds" j with `Int i -> i | _ -> 0 in
  let completed_at = match member "completed_at" j with `String s -> Some s | _ -> None in
  let card_set_id = match member "card_set_id" j with `Int i -> i | _ -> 0 in
  ((status, draft_type, seats, time_per_pick_seconds), (completed_at, card_set_id))

let handler_draft_session (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/draft_sessions - list all *)
  | `GET, ["api"; "draft_sessions"] ->
    let* rows = Db.collect_list Draft_session_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Draft_session_model.to_yojson (Draft_session_model.row_to_t r) in
         apply_projection_draft_session j) items) in
       respond_json 200 json)

  (* POST /api/draft_sessions - create *)
  | `POST, ["api"; "draft_sessions"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_draft_session j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Draft_session_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Draft_session_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Draft_session_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Draft_session_model.to_yojson (Draft_session_model.row_to_t r) in
                respond_json 201 (apply_projection_draft_session j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/draft_sessions/:id - get one *)
  | `GET, ["api"; "draft_sessions"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Draft_session_model.to_yojson (Draft_session_model.row_to_t r) in
          respond_json 200 (apply_projection_draft_session j)))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "draft_sessions"; id_str; "transitions"; "waitingforplayers-to-drafting"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Draft_session_model.row_to_t r in
          if rec_.status <> "WaitingForPlayers" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Drafting via DB *)
            respond_json 200 (`Assoc [("status", `String "Drafting")])))

  | `PATCH, ["api"; "draft_sessions"; id_str; "transitions"; "drafting-to-completed"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Draft_session_model.row_to_t r in
          if rec_.status <> "Drafting" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Completed via DB *)
            respond_json 200 (`Assoc [("status", `String "Completed")])))

  | `PATCH, ["api"; "draft_sessions"; id_str; "transitions"; "drafting-to-abandoned"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Draft_session_model.row_to_t r in
          if rec_.status <> "Drafting" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Abandoned via DB *)
            respond_json 200 (`Assoc [("status", `String "Abandoned")])))

  | `PATCH, ["api"; "draft_sessions"; id_str; "transitions"; "waitingforplayers-to-abandoned"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Draft_session_model.row_to_t r in
          if rec_.status <> "WaitingForPlayers" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Abandoned via DB *)
            respond_json 200 (`Assoc [("status", `String "Abandoned")])))

  | `PATCH, ["api"; "draft_sessions"; id_str; "transitions"; "completed-to-drafting"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Completed -> Drafting not allowed")))

  | `PATCH, ["api"; "draft_sessions"; id_str; "transitions"; "abandoned-to-drafting"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Draft_session_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Abandoned -> Drafting not allowed")))

  (* POST /api/draft-sessions/{id}/start - behavior start *)
  | `POST, ["api"; "draft_sessions"; id_str; "_id/start"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior start *)
       respond_json 204 (`Null))

  (* POST /api/draft-sessions/{id}/abandon - behavior abandon *)
  | `POST, ["api"; "draft_sessions"; id_str; "_id/abandon"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior abandon *)
       respond_json 204 (`Null))

  (* POST /api/draft-sessions/{id}/complete - behavior complete *)
  | `POST, ["api"; "draft_sessions"; id_str; "_id/complete"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior complete *)
       respond_json 204 (`Null))

  (* GET /api/draft-sessions/{id}/full - behavior is_full *)
  | `GET, ["api"; "draft_sessions"; id_str; "_id/full"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_full *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
