(* Dream handlers for TradeDispute *)
open Lwt.Syntax

let apply_projection_trade_dispute (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "opened_at" then ("opened_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "resolved_at" then ("resolved_at", v) else (k, v)) fields in
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

let validate_trade_dispute (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((not ((json_present j "resolved_at")) || ((json_string_opt j "status") = Some "Resolved"))) then errors := "resolved_at_requires_terminal_status" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let reason = match member "reason" j with `String s -> s | _ -> "" in
  let description = match member "description" j with `String s -> s | _ -> "" in
  let resolution = match member "resolution" j with `String s -> Some s | _ -> None in
  let opened_at = match member "opened_at" j with `String s -> s | _ -> "" in
  let resolved_at = match member "resolved_at" j with `String s -> Some s | _ -> None in
  let transaction_id = match member "transaction_id" j with `Int i -> i | _ -> 0 in
  let opened_by_id = match member "opened_by_id" j with `Int i -> i | _ -> 0 in
  let resolved_by_id = match member "resolved_by_id" j with `Int i -> Some i | _ -> None in
  ((status, reason, description, resolution), (opened_at, resolved_at, transaction_id, opened_by_id), resolved_by_id)

let handler_trade_dispute (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/trade_disputes - list all *)
  | `GET, ["api"; "trade_disputes"] ->
    let* rows = Db.collect_list Trade_dispute_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Trade_dispute_model.to_yojson (Trade_dispute_model.row_to_t r) in
         apply_projection_trade_dispute j) items) in
       respond_json 200 json)

  (* POST /api/trade_disputes - create *)
  | `POST, ["api"; "trade_disputes"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_trade_dispute j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Trade_dispute_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Trade_dispute_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Trade_dispute_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Trade_dispute_model.to_yojson (Trade_dispute_model.row_to_t r) in
                respond_json 201 (apply_projection_trade_dispute j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/trade_disputes/:id - get one *)
  | `GET, ["api"; "trade_disputes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_dispute_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Trade_dispute_model.to_yojson (Trade_dispute_model.row_to_t r) in
          respond_json 200 (apply_projection_trade_dispute j)))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "trade_disputes"; id_str; "transitions"; "open-to-underreview"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_dispute_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_dispute_model.row_to_t r in
          if rec_.status <> "Open" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to UnderReview via DB *)
            respond_json 200 (`Assoc [("status", `String "UnderReview")])))

  | `PATCH, ["api"; "trade_disputes"; id_str; "transitions"; "underreview-to-resolved"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_dispute_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_dispute_model.row_to_t r in
          if rec_.status <> "UnderReview" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Resolved via DB *)
            respond_json 200 (`Assoc [("status", `String "Resolved")])))

  | `PATCH, ["api"; "trade_disputes"; id_str; "transitions"; "underreview-to-escalated"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_dispute_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_dispute_model.row_to_t r in
          if rec_.status <> "UnderReview" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Escalated via DB *)
            respond_json 200 (`Assoc [("status", `String "Escalated")])))

  | `PATCH, ["api"; "trade_disputes"; id_str; "transitions"; "escalated-to-resolved"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_dispute_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_dispute_model.row_to_t r in
          if rec_.status <> "Escalated" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Resolved via DB *)
            respond_json 200 (`Assoc [("status", `String "Resolved")])))

  | `PATCH, ["api"; "trade_disputes"; id_str; "transitions"; "resolved-to-open"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_dispute_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Resolved -> Open not allowed")))

  (* POST /api/disputes/{id}/escalate - behavior escalate *)
  | `POST, ["api"; "trade_disputes"; id_str; "_id/escalate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior escalate *)
       respond_json 204 (`Null))

  (* POST /api/disputes/{id}/resolve - behavior resolve *)
  | `POST, ["api"; "trade_disputes"; id_str; "_id/resolve"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior resolve *)
       respond_json 204 (`Null))

  (* POST /api/disputes/{id}/close - behavior close_resolved *)
  | `POST, ["api"; "trade_disputes"; id_str; "_id/close"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior close_resolved *)
       respond_json 204 (`Null))

  (* POST /api/disputes/{id}/review - behavior review *)
  | `POST, ["api"; "trade_disputes"; id_str; "_id/review"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior review *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
