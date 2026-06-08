(* Dream handlers for TradeTransaction *)
open Lwt.Syntax

let apply_projection_trade_transaction (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
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

let validate_trade_transaction (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "platform_fee") with Some v -> v <= (Option.value (json_float_opt j "final_price") ~default:0.) | None -> true)) then errors := "Platform fee cannot exceed the final price" :: !errors;
  if not ((match (json_float_opt j "platform_fee") with Some v -> v >= 0. | None -> true)) then errors := "Platform fee must not be negative" :: !errors;
  if not ((match (json_float_opt j "final_price") with Some v -> v > 0. | None -> true)) then errors := "Transaction final price must be greater than zero" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "Completed") || ((json_present j "completed_at")))) then errors := "Completed transaction must have a completed_at timestamp" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let final_price = match member "final_price" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let platform_fee = match member "platform_fee" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let completed_at = match member "completed_at" j with `String s -> Some s | _ -> None in
  let listing_id = match member "listing_id" j with `Int i -> i | _ -> 0 in
  let buyer_id = match member "buyer_id" j with `Int i -> i | _ -> 0 in
  let seller_id = match member "seller_id" j with `Int i -> i | _ -> 0 in
  ((final_price, platform_fee, status, completed_at), (listing_id, buyer_id, seller_id))

let handler_trade_transaction (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/trade_transactions - list all *)
  | `GET, ["api"; "trade_transactions"] ->
    let* rows = Db.collect_list Trade_transaction_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Trade_transaction_model.to_yojson (Trade_transaction_model.row_to_t r) in
         apply_projection_trade_transaction j) items) in
       respond_json 200 json)

  (* GET /api/trade_transactions/:id - get one *)
  | `GET, ["api"; "trade_transactions"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Trade_transaction_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Trade_transaction_model.to_yojson (Trade_transaction_model.row_to_t r) in
          respond_json 200 (apply_projection_trade_transaction j)))

  (* POST /api/transactions/{id}/complete - behavior complete *)
  | `POST, ["api"; "trade_transactions"; id_str; "_id/complete"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior complete *)
       respond_json 204 (`Null))

  (* POST /api/transactions/{id}/refund - behavior refund *)
  | `POST, ["api"; "trade_transactions"; id_str; "_id/refund"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior refund *)
       respond_json 204 (`Null))

  (* POST /api/transactions/{id}/dispute - behavior open_dispute *)
  | `POST, ["api"; "trade_transactions"; id_str; "_id/dispute"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior open_dispute *)
       respond_json 204 (`Null))

  (* GET /api/transactions/{id}/seller-net - behavior seller_net *)
  | `GET, ["api"; "trade_transactions"; id_str; "_id/seller-net"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior seller_net *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
