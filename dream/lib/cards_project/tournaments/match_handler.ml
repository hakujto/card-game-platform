(* Dream handlers for Match *)
open Lwt.Syntax

let apply_projection_match (j : Yojson.Safe.t) : Yojson.Safe.t =
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

let validate_match (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not (((match (json_float_opt j "player1_wins") with Some v -> v >= 0. | None -> true) && (match (json_float_opt j "player2_wins") with Some v -> v >= 0. | None -> true))) then errors := "Win counts must not be negative" :: !errors;
  if not (((match (json_float_opt j "player1_wins") with Some v -> v >= 0. && v <= 2. | None -> true) && (match (json_float_opt j "player2_wins") with Some v -> v >= 0. && v <= 2. | None -> true))) then errors := "Win counts cannot exceed 2 in a best-of-3 match" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "BYE") || ((not (json_present j "player2_id"))))) then errors := "BYE match must not have a second player" :: !errors;
  if not ((not ((json_present j "ended_at")) || ((match (json_float_opt j "ended_at") with Some v -> v > (Option.value (json_float_opt j "started_at") ~default:0.) | None -> true)))) then errors := "Match end time must be after start time" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "Completed") || ((json_present j "started_at")))) then errors := "Completed match must have a start time" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let table_number = match member "table_number" j with `Int i -> Some i | _ -> None in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let player1_wins = match member "player1_wins" j with `Int i -> i | _ -> 0 in
  let player2_wins = match member "player2_wins" j with `Int i -> i | _ -> 0 in
  let started_at = match member "started_at" j with `String s -> Some s | _ -> None in
  let ended_at = match member "ended_at" j with `String s -> Some s | _ -> None in
  let result_notes = match member "result_notes" j with `String s -> Some s | _ -> None in
  let round_id = match member "round_id" j with `Int i -> i | _ -> 0 in
  let player1_id = match member "player1_id" j with `Int i -> i | _ -> 0 in
  let player2_id = match member "player2_id" j with `Int i -> Some i | _ -> None in
  ((table_number, status, player1_wins, player2_wins), (started_at, ended_at, result_notes, round_id), (player1_id, player2_id))

let handler_match (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/matches - list all *)
  | `GET, ["api"; "matches"] ->
    let* rows = Db.collect_list Match_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Match_model.to_yojson (Match_model.row_to_t r) in
         apply_projection_match j) items) in
       respond_json 200 json)

  (* POST /api/matches - create *)
  | `POST, ["api"; "matches"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_match j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Match_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Match_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Match_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Match_model.to_yojson (Match_model.row_to_t r) in
                respond_json 201 (apply_projection_match j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/matches/:id - get one *)
  | `GET, ["api"; "matches"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Match_model.to_yojson (Match_model.row_to_t r) in
          respond_json 200 (apply_projection_match j)))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "matches"; id_str; "transitions"; "pending-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Match_model.row_to_t r in
          if rec_.status <> "Pending" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Active via DB *)
            respond_json 200 (`Assoc [("status", `String "Active")])))

  | `PATCH, ["api"; "matches"; id_str; "transitions"; "active-to-completed"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Match_model.row_to_t r in
          if rec_.status <> "Active" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Completed via DB *)
            respond_json 200 (`Assoc [("status", `String "Completed")])))

  | `PATCH, ["api"; "matches"; id_str; "transitions"; "active-to-draw"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Match_model.row_to_t r in
          if rec_.status <> "Active" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Draw via DB *)
            respond_json 200 (`Assoc [("status", `String "Draw")])))

  | `PATCH, ["api"; "matches"; id_str; "transitions"; "pending-to-bye"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Match_model.row_to_t r in
          if rec_.status <> "Pending" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to BYE via DB *)
            respond_json 200 (`Assoc [("status", `String "BYE")])))

  | `PATCH, ["api"; "matches"; id_str; "transitions"; "completed-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Completed -> Active not allowed")))

  | `PATCH, ["api"; "matches"; id_str; "transitions"; "draw-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Draw -> Active not allowed")))

  | `PATCH, ["api"; "matches"; id_str; "transitions"; "bye-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Match_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition BYE -> Active not allowed")))

  (* POST /api/matches/{id}/record - behavior record_result *)
  | `POST, ["api"; "matches"; id_str; "_id/record"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior record_result *)
       respond_json 204 (`Null))

  (* POST /api/matches/{id}/finalize - behavior finalize_result *)
  | `POST, ["api"; "matches"; id_str; "_id/finalize"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior finalize_result *)
       respond_json 204 (`Null))

  (* GET /api/matches/{id}/winner - behavior determine_winner *)
  | `GET, ["api"; "matches"; id_str; "_id/winner"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior determine_winner *)
       respond_json 204 (`Null))

  (* POST /api/matches/{id}/concede - behavior concede *)
  | `POST, ["api"; "matches"; id_str; "_id/concede"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior concede *)
       respond_json 204 (`Null))

  (* POST /api/matches/{id}/draw - behavior draw *)
  | `POST, ["api"; "matches"; id_str; "_id/draw"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior draw *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
