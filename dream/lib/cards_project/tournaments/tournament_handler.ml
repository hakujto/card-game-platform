(* Dream handlers for Tournament *)
open Lwt.Syntax

let apply_projection_tournament (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "start_time" then ("start_time", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "end_time" then ("end_time", v) else (k, v)) fields in
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

let validate_tournament (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "max_players") with Some v -> v >= 2. && v <= 512. | None -> true)) then errors := "Tournament must allow between 2 and 512 players" :: !errors;
  if not ((match (json_float_opt j "entry_fee") with Some v -> v >= 0. | None -> true)) then errors := "Entry fee must not be negative" :: !errors;
  if not ((match (json_float_opt j "prize_pool") with Some v -> v >= 0. | None -> true)) then errors := "Prize pool must not be negative" :: !errors;
  if not ((not ((json_present j "end_time")) || ((match (json_float_opt j "end_time") with Some v -> v > (Option.value (json_float_opt j "start_time") ~default:0.) | None -> true)))) then errors := "End time must be after start time" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let description = match member "description" j with `String s -> Some s | _ -> None in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let format = match member "format" j with `String s -> s | _ -> "" in
  let tournament_type = match member "tournament_type" j with `String s -> s | _ -> "" in
  let max_players = match member "max_players" j with `Int i -> i | _ -> 0 in
  let entry_fee = match member "entry_fee" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let prize_pool = match member "prize_pool" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let start_time = match member "start_time" j with `String s -> s | _ -> "" in
  let end_time = match member "end_time" j with `String s -> Some s | _ -> None in
  let is_online = match member "is_online" j with `Bool b -> b | _ -> false in
  let location = match member "location" j with `String s -> Some s | _ -> None in
  let rules_text = match member "rules_text" j with `String s -> Some s | _ -> None in
  let season_id = match member "season_id" j with `Int i -> i | _ -> 0 in
  let organizer_id = match member "organizer_id" j with `Int i -> i | _ -> 0 in
  ((name, description, status, format), (tournament_type, max_players, entry_fee, prize_pool), (start_time, end_time, is_online, location), (rules_text, season_id, organizer_id))

let handler_tournament (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/tournaments - list with optional ?q= search *)
  | `GET, ["api"; "tournaments"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Tournament_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Tournament_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)
           || (match (Tournament_model.row_to_t r).description with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Tournament_model.to_yojson (Tournament_model.row_to_t r) in
         apply_projection_tournament j) filtered) in
       respond_json 200 json)

  (* POST /api/tournaments - create *)
  | `POST, ["api"; "tournaments"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_tournament j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Tournament_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Tournament_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Tournament_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Tournament_model.to_yojson (Tournament_model.row_to_t r) in
                respond_json 201 (apply_projection_tournament j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/tournaments/:id - get one *)
  | `GET, ["api"; "tournaments"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Tournament_model.to_yojson (Tournament_model.row_to_t r) in
          respond_json 200 (apply_projection_tournament j)))

  (* PUT /api/tournaments/:id - full update *)
  | `PUT, ["api"; "tournaments"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_tournament j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((name, description, status, format), (tournament_type, max_players, entry_fee, prize_pool), (start_time, end_time, is_online, location), (rules_text, season_id, organizer_id)) = params in
          let upd_params = ((name, description, status, format), (tournament_type, max_players, entry_fee, prize_pool), (start_time, end_time, is_online, location), (rules_text, season_id, organizer_id, id)) in
          let* upd = Db.exec Tournament_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Tournament_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Tournament_model.to_yojson (Tournament_model.row_to_t r) in
                respond_json 200 (apply_projection_tournament j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "draft-to-registration"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Tournament_model.row_to_t r in
          if rec_.status <> "Draft" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Registration via DB *)
            respond_json 200 (`Assoc [("status", `String "Registration")])))

  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "registration-to-ongoing"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Tournament_model.row_to_t r in
          if rec_.status <> "Registration" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Ongoing via DB *)
            respond_json 200 (`Assoc [("status", `String "Ongoing")])))

  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "registration-to-cancelled"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Tournament_model.row_to_t r in
          if rec_.status <> "Registration" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Cancelled via DB *)
            respond_json 200 (`Assoc [("status", `String "Cancelled")])))

  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "ongoing-to-completed"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Tournament_model.row_to_t r in
          if rec_.status <> "Ongoing" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Completed via DB *)
            respond_json 200 (`Assoc [("status", `String "Completed")])))

  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "ongoing-to-cancelled"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Tournament_model.row_to_t r in
          if rec_.status <> "Ongoing" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Cancelled via DB *)
            respond_json 200 (`Assoc [("status", `String "Cancelled")])))

  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "completed-to-draft"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Completed -> Draft not allowed")))

  | `PATCH, ["api"; "tournaments"; id_str; "transitions"; "cancelled-to-draft"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Tournament_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Cancelled -> Draft not allowed")))

  (* POST /api/tournaments/{id}/start - behavior start *)
  | `POST, ["api"; "tournaments"; id_str; "_id/start"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior start *)
       respond_json 204 (`Null))

  (* POST /api/tournaments/{id}/cancel - behavior cancel *)
  | `POST, ["api"; "tournaments"; id_str; "_id/cancel"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior cancel *)
       respond_json 204 (`Null))

  (* POST /api/tournaments/{id}/complete - behavior complete *)
  | `POST, ["api"; "tournaments"; id_str; "_id/complete"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior complete *)
       respond_json 204 (`Null))

  (* POST /api/tournaments/{id}/rounds - behavior generate_round *)
  | `POST, ["api"; "tournaments"; id_str; "_id/rounds"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior generate_round *)
       respond_json 204 (`Null))

  (* GET /api/tournaments/{id}/prizes - behavior calculate_prize_distribution *)
  | `GET, ["api"; "tournaments"; id_str; "_id/prizes"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior calculate_prize_distribution *)
       respond_json 204 (`Null))

  (* POST /api/tournaments/{id}/register - behavior register_player *)
  | `POST, ["api"; "tournaments"; id_str; "_id/register"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior register_player *)
       respond_json 204 (`Null))

  (* GET /api/tournaments/{id}/full - behavior is_full *)
  | `GET, ["api"; "tournaments"; id_str; "_id/full"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_full *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
