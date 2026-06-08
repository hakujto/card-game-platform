(* Dream handlers for OrderItem *)
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

let validate_order_item (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "quantity") with Some v -> v > 0. | None -> true)) then errors := "Order item quantity must be greater than zero" :: !errors;
  if not ((match (json_float_opt j "price_at_purchase") with Some v -> v >= 0. | None -> true)) then errors := "Price at purchase must not be negative" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let quantity = match member "quantity" j with `Int i -> i | _ -> 0 in
  let price_at_purchase = match member "price_at_purchase" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let foil = match member "foil" j with `Bool b -> b | _ -> false in
  let order_id = match member "order_id" j with `Int i -> i | _ -> 0 in
  let product_id = match member "product_id" j with `Int i -> i | _ -> 0 in
  ((quantity, price_at_purchase, foil, order_id), product_id)

let handler_order_item (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/order_items - list all *)
  | `GET, ["api"; "order_items"] ->
    let* rows = Db.collect_list Order_item_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Order_item_model.to_yojson (Order_item_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/order_items - create *)
  | `POST, ["api"; "order_items"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_order_item j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Order_item_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Order_item_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Order_item_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Order_item_model.to_yojson (Order_item_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/order_items/:id - get one *)
  | `GET, ["api"; "order_items"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Order_item_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Order_item_model.to_yojson (Order_item_model.row_to_t r) in
          respond_json 200 (j)))

  (* DELETE /api/order_items/:id *)
  | `DELETE, ["api"; "order_items"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Order_item_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* GET /api/order-items/{id}/total - behavior line_total *)
  | `GET, ["api"; "order_items"; id_str; "_id/total"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior line_total *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
