(* Dream handlers for Product *)
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

let validate_product (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "price") with Some v -> v > 0. | None -> true)) then errors := "Product price must be greater than zero" :: !errors;
  if not ((match (json_float_opt j "stock") with Some v -> v >= 0. | None -> true)) then errors := "Product stock must not be negative" :: !errors;
  if not ((match (json_float_opt j "discount_percent") with Some v -> v >= 0. && v <= 100. | None -> true)) then errors := "Product discount percent must be between 0 and 100" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let name = match member "name" j with `String s -> s | _ -> "" in
  let product_type = match member "product_type" j with `String s -> s | _ -> "" in
  let price = match member "price" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let stock = match member "stock" j with `Int i -> i | _ -> 0 in
  let active = match member "active" j with `Bool b -> b | _ -> false in
  let discount_percent = match member "discount_percent" j with `Int i -> i | _ -> 0 in
  let description = match member "description" j with `String s -> Some s | _ -> None in
  let image_url = match member "image_url" j with `String s -> Some s | _ -> None in
  let featured = match member "featured" j with `Bool b -> b | _ -> false in
  let card_id = match member "card_id" j with `Int i -> Some i | _ -> None in
  let card_set_id = match member "card_set_id" j with `Int i -> Some i | _ -> None in
  ((name, product_type, price, stock), (active, discount_percent, description, image_url), (featured, card_id, card_set_id))

let handler_product (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/products - list with optional ?q= search *)
  | `GET, ["api"; "products"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Product_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Product_model.row_to_t r).name in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)
           || (match (Product_model.row_to_t r).description with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Product_model.to_yojson (Product_model.row_to_t r) in
         j) filtered) in
       respond_json 200 json)

  (* POST /api/products - create *)
  | `POST, ["api"; "products"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_product j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Product_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Product_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Product_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Product_model.to_yojson (Product_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/products/:id - get one *)
  | `GET, ["api"; "products"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Product_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Product_model.to_yojson (Product_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/products/:id - full update *)
  | `PUT, ["api"; "products"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_product j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((name, product_type, price, stock), (active, discount_percent, description, image_url), (featured, card_id, card_set_id)) = params in
          let upd_params = ((name, product_type, price, stock), (active, discount_percent, description, image_url), (featured, card_id, card_set_id, id)) in
          let* upd = Db.exec Product_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Product_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Product_model.to_yojson (Product_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* POST /api/products/{id}/activate - behavior activate *)
  | `POST, ["api"; "products"; id_str; "_id/activate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior activate *)
       respond_json 204 (`Null))

  (* POST /api/products/{id}/deactivate - behavior deactivate *)
  | `POST, ["api"; "products"; id_str; "_id/deactivate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior deactivate *)
       respond_json 204 (`Null))

  (* PATCH /api/products/{id}/discount - behavior apply_discount *)
  | `PATCH, ["api"; "products"; id_str; "_id/discount"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior apply_discount *)
       respond_json 204 (`Null))

  (* POST /api/products/{id}/restock - behavior restock *)
  | `POST, ["api"; "products"; id_str; "_id/restock"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior restock *)
       respond_json 204 (`Null))

  (* GET /api/products/{id}/effective-price - behavior effective_price *)
  | `GET, ["api"; "products"; id_str; "_id/effective-price"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior effective_price *)
       respond_json 204 (`Null))

  (* GET /api/products/{id}/in-stock - behavior is_in_stock *)
  | `GET, ["api"; "products"; id_str; "_id/in-stock"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_in_stock *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
