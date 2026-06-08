(* Dream handlers for TradeBid *)
open Lwt.Syntax

let apply_projection_trade_bid (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "placed_at" then ("placed_at", v) else (k, v)) fields in
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

let validate_trade_bid (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "amount") with Some v -> v > 0. | None -> true)) then errors := "Bid amount must be greater than zero" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let amount = match member "amount" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let placed_at = match member "placed_at" j with `String s -> s | _ -> "" in
  let is_winning = match member "is_winning" j with `Bool b -> b | _ -> false in
  let listing_id = match member "listing_id" j with `Int i -> i | _ -> 0 in
  let bidder_id = match member "bidder_id" j with `Int i -> i | _ -> 0 in
  ((amount, placed_at, is_winning, listing_id), bidder_id)

let handler_trade_bid (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/trade_bids - list all *)
  | `GET, ["api"; "trade_bids"] ->
    let* rows = Db.collect_list Trade_bid_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Trade_bid_model.to_yojson (Trade_bid_model.row_to_t r) in
         apply_projection_trade_bid j) items) in
       respond_json 200 json)

  (* POST /api/trade_bids - create *)
  | `POST, ["api"; "trade_bids"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_trade_bid j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Trade_bid_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Trade_bid_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Trade_bid_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Trade_bid_model.to_yojson (Trade_bid_model.row_to_t r) in
                respond_json 201 (apply_projection_trade_bid j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/trade_bids/:id - get one *)
  | `GET, ["api"; "trade_bids"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_bid_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Trade_bid_model.to_yojson (Trade_bid_model.row_to_t r) in
          respond_json 200 (apply_projection_trade_bid j)))

  (* GET /api/bids/{id}/outbid - behavior outbid_by *)
  | `GET, ["api"; "trade_bids"; id_str; "_id/outbid"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior outbid_by *)
       respond_json 204 (`Null))

  (* DELETE /api/bids/{id} - behavior retract *)
  | `GET, ["api"; "trade_bids"; id_str; "_id"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior retract *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
