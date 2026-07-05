(* Dream handlers for Order *)
open Lwt.Syntax

(* ── Lifecycle hooks ─────────────────────────────────────────────────── *)
let hook_assign_currency_default () =
  (* TODO: implement assign_currency_default *)
  ()

let hook_notify_status_change () =
  (* TODO: implement notify_status_change *)
  ()

let apply_projection_order (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k ["payment_reference"])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "paid_at" then ("paid_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "shipped_at" then ("shipped_at", v) else (k, v)) fields in
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

let validate_order (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "total") with Some v -> v >= 0. | None -> true)) then errors := "Order total must not be negative" :: !errors;
  if not ((match (json_float_opt j "discount_applied") with Some v -> v <= (Option.value (json_float_opt j "total") ~default:0.) | None -> true)) then errors := "Discount applied cannot exceed order total" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "Paid") || ((json_present j "paid_at")))) then errors := "Paid order must have paid_at set" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "Shipped") || ((json_present j "tracking_number")))) then errors := "Shipped order must have a tracking number" :: !errors;
  if not ((not ((json_present j "shipped_at")) || ((json_string_opt j "status") = Some "Shipped"))) then errors := "shipped_at_requires_shipped_status" :: !errors;
  (match json_string_opt j "currency" with
   | Some v when not (Re.execp (Re.compile (Re.Perl.re ~opts:[`Anchored] "[A-Z]{3}")) v) ->
     errors := "currency: invalid format" :: !errors
   | _ -> ());
  if json_string_opt j "status" = Some "Shipped" && not (json_present j "tracking_number") then
    errors := "tracking_number is required" :: !errors;
  if json_string_opt j "status" = Some "Paid" && not (json_present j "paid_at") then
    errors := "paid_at is required" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let total = match member "total" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let discount_applied = match member "discount_applied" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let currency = match member "currency" j with `String s -> s | _ -> "" in
  let payment_method = match member "payment_method" j with `String s -> Some s | _ -> None in
  let payment_reference = match member "payment_reference" j with `String s -> Some s | _ -> None in
  let shipping_address = match member "shipping_address" j with `String s -> Some s | _ -> None in
  let tracking_number = match member "tracking_number" j with `String s -> Some s | _ -> None in
  let paid_at = match member "paid_at" j with `String s -> Some s | _ -> None in
  let shipped_at = match member "shipped_at" j with `String s -> Some s | _ -> None in
  let player_id = match member "player_id" j with `Int i -> i | _ -> 0 in
  let coupon_id = match member "coupon_id" j with `Int i -> Some i | _ -> None in
  ((status, total, discount_applied, currency), (payment_method, payment_reference, shipping_address, tracking_number), (paid_at, shipped_at, player_id, coupon_id))

let handler_order (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/orders - list all *)
  | `GET, ["api"; "orders"] ->
    let* rows = Db.collect_list Order_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Order_model.to_yojson (Order_model.row_to_t r) in
         apply_projection_order j) items) in
       respond_json 200 json)

  (* POST /api/orders - create *)
  | `POST, ["api"; "orders"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_order j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Order_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Order_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Order_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Order_model.to_yojson (Order_model.row_to_t r) in
                respond_json 201 (apply_projection_order j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/orders/:id - get one *)
  | `GET, ["api"; "orders"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          let owner_ok =
            match Dream.header req "X-User-Id" with
            | None -> false
            | Some uid_str ->
              (match int_of_string_opt uid_str with
               | None -> false
               | Some uid -> (rec_).player_id = uid)
          in
          if not owner_ok then respond_json 403 (`String "You do not own this resource.")
          else
          let j = Order_model.to_yojson rec_ in
          respond_json 200 (apply_projection_order j)))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "orders"; id_str; "transitions"; "pending-to-paid"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Pending" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Paid via DB *)
            respond_json 200 (`Assoc [("status", `String "Paid")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "paid-to-processing"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Paid" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Processing via DB *)
            respond_json 200 (`Assoc [("status", `String "Processing")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "processing-to-shipped"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Processing" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Shipped via DB *)
            respond_json 200 (`Assoc [("status", `String "Shipped")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "shipped-to-completed"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Shipped" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Completed via DB *)
            respond_json 200 (`Assoc [("status", `String "Completed")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "pending-to-cancelled"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Pending" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Cancelled via DB *)
            respond_json 200 (`Assoc [("status", `String "Cancelled")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "paid-to-cancelled"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Paid" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Cancelled via DB *)
            respond_json 200 (`Assoc [("status", `String "Cancelled")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "completed-to-refunded"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Order_model.row_to_t r in
          if rec_.status <> "Completed" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Refunded via DB *)
            respond_json 200 (`Assoc [("status", `String "Refunded")])))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "refunded-to-completed"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Refunded -> Completed not allowed")))

  | `PATCH, ["api"; "orders"; id_str; "transitions"; "completed-to-cancelled"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Completed -> Cancelled not allowed")))

  (* DELETE /api/orders/{id}/cancel - behavior cancel *)
  | `GET, ["api"; "orders"; id_str; "_id/cancel"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior cancel *)
       respond_json 204 (`Null))

  (* POST /api/orders/{id}/pay - behavior pay *)
  | `POST, ["api"; "orders"; id_str; "_id/pay"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* @guard: TODO: evaluate guard condition — return 422 if not met *)
       (* TODO: implement behavior pay *)
       respond_json 204 (`Null))

  (* POST /api/orders/{id}/process-payment - behavior process_payment *)
  | `POST, ["api"; "orders"; id_str; "_id/process-payment"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior process_payment *)
       respond_json 204 (`Null))

  (* GET /api/orders/{id}/total - behavior calculate_total *)
  | `GET, ["api"; "orders"; id_str; "_id/total"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior calculate_total *)
       respond_json 204 (`Null))

  (* PATCH /api/orders/{id}/discount - behavior apply_discount *)
  | `PATCH, ["api"; "orders"; id_str; "_id/discount"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior apply_discount *)
       respond_json 204 (`Null))

  (* POST /api/orders/{id}/refund - behavior refund *)
  | `POST, ["api"; "orders"; id_str; "_id/refund"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior refund *)
       respond_json 204 (`Null))

  (* TODO: @on(status = Shipped) → notify_shipped — trigger in PATCH /api/orders/:id/set_status *)

  | _ -> respond_json 404 (`String "Not found")
