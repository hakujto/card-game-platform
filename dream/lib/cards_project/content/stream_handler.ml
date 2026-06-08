(* Dream handlers for Stream *)
open Lwt.Syntax

let apply_projection_stream (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "scheduled_start" then ("scheduled_start", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "actual_start" then ("actual_start", v) else (k, v)) fields in
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

let validate_stream (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "viewer_count_peak") with Some v -> v >= 0. | None -> true)) then errors := "Peak viewer count must not be negative" :: !errors;
  if not ((not ((json_present j "actual_start")) || ((json_string_opt j "status") = Some "Live"))) then errors := "actual_start_requires_live_or_ended" :: !errors;
  if not ((not ((json_present j "ended_at")) || ((json_string_opt j "status") = Some "Ended"))) then errors := "ended_at can only be set when stream status is Ended" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let title = match member "title" j with `String s -> s | _ -> "" in
  let stream_url = match member "stream_url" j with `String s -> s | _ -> "" in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let platform = match member "platform" j with `String s -> s | _ -> "" in
  let language = match member "language" j with `String s -> s | _ -> "" in
  let is_official = match member "is_official" j with `Bool b -> b | _ -> false in
  let viewer_count_peak = match member "viewer_count_peak" j with `Int i -> i | _ -> 0 in
  let scheduled_start = match member "scheduled_start" j with `String s -> s | _ -> "" in
  let actual_start = match member "actual_start" j with `String s -> Some s | _ -> None in
  let ended_at = match member "ended_at" j with `String s -> Some s | _ -> None in
  let vod_url = match member "vod_url" j with `String s -> Some s | _ -> None in
  let tournament_id = match member "tournament_id" j with `Int i -> Some i | _ -> None in
  let streamer_id = match member "streamer_id" j with `Int i -> i | _ -> 0 in
  ((title, stream_url, status, platform), (language, is_official, viewer_count_peak, scheduled_start), (actual_start, ended_at, vod_url, tournament_id), streamer_id)

let handler_stream (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/streams - list with optional ?q= search *)
  | `GET, ["api"; "streams"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Stream_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Stream_model.row_to_t r).title in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Stream_model.to_yojson (Stream_model.row_to_t r) in
         apply_projection_stream j) filtered) in
       respond_json 200 json)

  (* POST /api/streams - create *)
  | `POST, ["api"; "streams"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_stream j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Stream_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Stream_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Stream_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Stream_model.to_yojson (Stream_model.row_to_t r) in
                respond_json 201 (apply_projection_stream j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/streams/:id - get one *)
  | `GET, ["api"; "streams"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Stream_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Stream_model.to_yojson (Stream_model.row_to_t r) in
          respond_json 200 (apply_projection_stream j)))

  (* PUT /api/streams/:id - full update *)
  | `PUT, ["api"; "streams"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_stream j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((title, stream_url, status, platform), (language, is_official, viewer_count_peak, scheduled_start), (actual_start, ended_at, vod_url, tournament_id), streamer_id) = params in
          let upd_params = ((title, stream_url, status, platform), (language, is_official, viewer_count_peak, scheduled_start), (actual_start, ended_at, vod_url, tournament_id), (streamer_id, id)) in
          let* upd = Db.exec Stream_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Stream_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Stream_model.to_yojson (Stream_model.row_to_t r) in
                respond_json 200 (apply_projection_stream j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "streams"; id_str; "transitions"; "scheduled-to-live"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Stream_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Stream_model.row_to_t r in
          if rec_.status <> "Scheduled" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Live via DB *)
            respond_json 200 (`Assoc [("status", `String "Live")])))

  | `PATCH, ["api"; "streams"; id_str; "transitions"; "live-to-ended"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Stream_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Stream_model.row_to_t r in
          if rec_.status <> "Live" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Ended via DB *)
            respond_json 200 (`Assoc [("status", `String "Ended")])))

  | `PATCH, ["api"; "streams"; id_str; "transitions"; "ended-to-live"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Stream_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Ended -> Live not allowed")))

  (* POST /api/streams/{id}/live - behavior go_live *)
  | `POST, ["api"; "streams"; id_str; "_id/live"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior go_live *)
       respond_json 204 (`Null))

  (* POST /api/streams/{id}/end - behavior end *)
  | `POST, ["api"; "streams"; id_str; "_id/end"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior end *)
       respond_json 204 (`Null))

  (* PATCH /api/streams/{id}/viewers - behavior update_viewer_peak *)
  | `PATCH, ["api"; "streams"; id_str; "_id/viewers"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior update_viewer_peak *)
       respond_json 204 (`Null))

  (* GET /api/streams/{id}/duration - behavior duration_minutes *)
  | `GET, ["api"; "streams"; id_str; "_id/duration"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior duration_minutes *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
