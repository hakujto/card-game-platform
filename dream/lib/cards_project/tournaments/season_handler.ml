(* Dream handlers for Season *)
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

let validate_season (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "end_date") with Some v -> v > (Option.value (json_float_opt j "start_date") ~default:0.) | None -> true)) then errors := "Season end date must be after start date" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let start_date = match member "start_date" j with `String s -> s | _ -> "" in
  let end_date = match member "end_date" j with `String s -> s | _ -> "" in
  let format = match member "format" j with `String s -> s | _ -> "" in
  let is_active = match member "is_active" j with `Bool b -> b | _ -> false in
  let reward_description = match member "reward_description" j with `String s -> Some s | _ -> None in
  ((name, start_date, end_date, format), (is_active, reward_description))

let handler_season (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/seasons - list with optional ?q= search *)
  | `GET, ["api"; "seasons"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Season_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Season_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Season_model.to_yojson (Season_model.row_to_t r) in
         j) filtered) in
       respond_json 200 json)

  (* POST /api/seasons - create *)
  | `POST, ["api"; "seasons"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_season j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Season_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Season_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Season_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Season_model.to_yojson (Season_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/seasons/:id - get one *)
  | `GET, ["api"; "seasons"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Season_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Season_model.to_yojson (Season_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/seasons/:id - full update *)
  | `PUT, ["api"; "seasons"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_season j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((name, start_date, end_date, format), (is_active, reward_description)) = params in
          let upd_params = ((name, start_date, end_date, format), (is_active, reward_description, id)) in
          let* upd = Db.exec Season_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Season_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Season_model.to_yojson (Season_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* POST /api/seasons/{id}/activate - behavior activate *)
  | `POST, ["api"; "seasons"; id_str; "_id/activate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior activate *)
       respond_json 204 (`Null))

  (* POST /api/seasons/{id}/deactivate - behavior deactivate *)
  | `POST, ["api"; "seasons"; id_str; "_id/deactivate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior deactivate *)
       respond_json 204 (`Null))

  (* POST /api/seasons/{id}/finalize - behavior finalize_rewards *)
  | `POST, ["api"; "seasons"; id_str; "_id/finalize"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior finalize_rewards *)
       respond_json 204 (`Null))

  (* GET /api/seasons/{id}/ongoing - behavior is_ongoing *)
  | `GET, ["api"; "seasons"; id_str; "_id/ongoing"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_ongoing *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
