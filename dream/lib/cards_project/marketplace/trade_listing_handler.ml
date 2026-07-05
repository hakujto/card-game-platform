(* Dream handlers for TradeListing *)
open Lwt.Syntax

let apply_projection_trade_listing (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "expires_at" then ("expires_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "auction_end_time" then ("auction_end_time", v) else (k, v)) fields in
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

let validate_trade_listing (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "quantity") with Some v -> v >= 1. && v <= 9999. | None -> true)) then errors := "Listing quantity must be between 1 and 9999" :: !errors;
  if not ((not ((json_string_opt j "listing_type") = Some "FixedPrice") || ((json_present j "asking_price")))) then errors := "Fixed price listing must have an asking price" :: !errors;
  if not ((not ((json_string_opt j "listing_type") = Some "Auction") || ((json_present j "auction_start_price") && (json_present j "auction_end_time")))) then errors := "Auction listing must have a start price and end time" :: !errors;
  if json_string_opt j "listing_type" = Some "FixedPrice" && not (json_present j "asking_price") then
    errors := "asking_price is required" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let public_id = match member "public_id" j with `String s -> s | _ -> "" in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let listing_type = match member "listing_type" j with `String s -> s | _ -> "" in
  let asking_price = match member "asking_price" j with `Float f -> Some f | `Int i -> Some (float_of_int i) | _ -> None in
  let auction_start_price = match member "auction_start_price" j with `Float f -> Some f | `Int i -> Some (float_of_int i) | _ -> None in
  let auction_current_bid = match member "auction_current_bid" j with `Float f -> Some f | `Int i -> Some (float_of_int i) | _ -> None in
  let auction_end_time = match member "auction_end_time" j with `String s -> Some s | _ -> None in
  let foil = match member "foil" j with `Bool b -> b | _ -> false in
  let condition = match member "condition" j with `String s -> s | _ -> "" in
  let quantity = match member "quantity" j with `Int i -> i | _ -> 0 in
  let description = match member "description" j with `String s -> Some s | _ -> None in
  let expires_at = match member "expires_at" j with `String s -> Some s | _ -> None in
  let seller_id = match member "seller_id" j with `Int i -> i | _ -> 0 in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  ((public_id, status, listing_type, asking_price), (auction_start_price, auction_current_bid, auction_end_time, foil), (condition, quantity, description, expires_at), (seller_id, card_id))

let handler_trade_listing (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/trade_listings - list with optional ?q= search *)
  | `GET, ["api"; "trade_listings"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Trade_listing_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           (match (Trade_listing_model.row_to_t r).description with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Trade_listing_model.to_yojson (Trade_listing_model.row_to_t r) in
         apply_projection_trade_listing j) filtered) in
       respond_json 200 json)

  (* POST /api/trade_listings - create *)
  | `POST, ["api"; "trade_listings"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_trade_listing j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Trade_listing_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Trade_listing_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Trade_listing_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Trade_listing_model.to_yojson (Trade_listing_model.row_to_t r) in
                respond_json 201 (apply_projection_trade_listing j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/trade_listings/:id - get one *)
  | `GET, ["api"; "trade_listings"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Trade_listing_model.to_yojson (Trade_listing_model.row_to_t r) in
          respond_json 200 (apply_projection_trade_listing j)))

  (* PATCH /api/trade_listings/:id - partial update *)
  | `PATCH, ["api"; "trade_listings"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          let params = extract_insert_params j in
          let ((public_id, _status, listing_type, asking_price), (auction_start_price, auction_current_bid, auction_end_time, foil), (condition, quantity, description, expires_at), (seller_id, card_id)) = params in
          let upd_params = ((public_id, listing_type, asking_price, auction_start_price), (auction_current_bid, auction_end_time, foil, condition), (quantity, description, expires_at, seller_id), (card_id, id)) in
          let* upd = Db.exec Trade_listing_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Trade_listing_model.to_yojson (Trade_listing_model.row_to_t r) in
                respond_json 200 (apply_projection_trade_listing j)))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "trade_listings"; id_str; "transitions"; "pending-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_listing_model.row_to_t r in
          if rec_.status <> "Pending" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Active via DB *)
            respond_json 200 (`Assoc [("status", `String "Active")])))

  | `PATCH, ["api"; "trade_listings"; id_str; "transitions"; "active-to-sold"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_listing_model.row_to_t r in
          if rec_.status <> "Active" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Sold via DB *)
            respond_json 200 (`Assoc [("status", `String "Sold")])))

  | `PATCH, ["api"; "trade_listings"; id_str; "transitions"; "active-to-expired"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_listing_model.row_to_t r in
          if rec_.status <> "Active" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Expired via DB *)
            respond_json 200 (`Assoc [("status", `String "Expired")])))

  | `PATCH, ["api"; "trade_listings"; id_str; "transitions"; "active-to-cancelled"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Trade_listing_model.row_to_t r in
          if rec_.status <> "Active" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Cancelled via DB *)
            respond_json 200 (`Assoc [("status", `String "Cancelled")])))

  | `PATCH, ["api"; "trade_listings"; id_str; "transitions"; "sold-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Sold -> Active not allowed")))

  | `PATCH, ["api"; "trade_listings"; id_str; "transitions"; "expired-to-active"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_listing_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Expired -> Active not allowed")))

  (* POST /api/trade-listings/{id}/close - behavior close *)
  | `POST, ["api"; "trade_listings"; id_str; "_id/close"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior close *)
       respond_json 204 (`Null))

  (* PATCH /api/trade-listings/{id}/extend - behavior extend *)
  | `PATCH, ["api"; "trade_listings"; id_str; "_id/extend"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior extend *)
       respond_json 204 (`Null))

  (* DELETE /api/trade-listings/{id}/cancel - behavior cancel *)
  | `GET, ["api"; "trade_listings"; id_str; "_id/cancel"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* @guard: TODO: evaluate guard condition — return 422 if not met *)
       (* TODO: implement behavior cancel *)
       respond_json 204 (`Null))

  (* GET /api/trade-listings/{id}/expired - behavior is_expired *)
  | `GET, ["api"; "trade_listings"; id_str; "_id/expired"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_expired *)
       respond_json 204 (`Null))

  (* POST /api/trade-listings/{id}/finalize - behavior finalize_auction *)
  | `POST, ["api"; "trade_listings"; id_str; "_id/finalize"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* RBAC: allowed roles: admin, seller — TODO: check X-Role header *)
       (* TODO: implement behavior finalize_auction *)
       respond_json 204 (`Null))

  (* TODO: @on(status = Sold) → finalize_auction — trigger in PATCH /api/trade_listings/:id/set_status *)

  | _ -> respond_json 404 (`String "Not found")
