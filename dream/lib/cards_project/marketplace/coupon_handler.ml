(* Dream handlers for Coupon *)
open Lwt.Syntax

let apply_projection_coupon (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k ["uses_count"; "max_uses"])) fields in
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

let validate_coupon (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "valid_until") with Some v -> v > (Option.value (json_float_opt j "valid_from") ~default:0.) | None -> true)) then errors := "Coupon expiry must be after its start date" :: !errors;
  if not ((match (json_float_opt j "discount_value") with Some v -> v > 0. | None -> true)) then errors := "Discount value must be greater than zero" :: !errors;
  if not ((not ((json_string_opt j "discount_type") = Some "Percent") || ((match (json_float_opt j "discount_value") with Some v -> v >= 1. && v <= 100. | None -> true)))) then errors := "Percent discount must be between 1 and 100" :: !errors;
  if not ((not ((json_present j "max_uses")) || ((match (json_float_opt j "uses_count") with Some v -> v <= (Option.value (json_float_opt j "max_uses") ~default:0.) | None -> true)))) then errors := "Coupon uses count cannot exceed max_uses" :: !errors;
  (match json_float_opt j "discount_value" with
   | Some v when v < 0.01 -> errors := "discount_value: must be >= 0.01" :: !errors
   | _ -> ());
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let code = match member "code" j with `String s -> s | _ -> "" in
  let discount_type = match member "discount_type" j with `String s -> s | _ -> "" in
  let discount_value = match member "discount_value" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let min_order_value = match member "min_order_value" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let max_uses = match member "max_uses" j with `Int i -> Some i | _ -> None in
  let uses_count = match member "uses_count" j with `Int i -> i | _ -> 0 in
  let valid_from = match member "valid_from" j with `String s -> s | _ -> "" in
  let valid_until = match member "valid_until" j with `String s -> s | _ -> "" in
  let is_active = match member "is_active" j with `Bool b -> b | _ -> false in
  ((code, discount_type, discount_value, min_order_value), (max_uses, uses_count, valid_from, valid_until), is_active)

let handler_coupon (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/coupons - list with optional ?q= search *)
  | `GET, ["api"; "coupons"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Coupon_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Coupon_model.row_to_t r).code in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Coupon_model.to_yojson (Coupon_model.row_to_t r) in
         apply_projection_coupon j) filtered) in
       respond_json 200 json)

  (* POST /api/coupons - create *)
  | `POST, ["api"; "coupons"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_coupon j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Coupon_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Coupon_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Coupon_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Coupon_model.to_yojson (Coupon_model.row_to_t r) in
                respond_json 201 (apply_projection_coupon j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/coupons/:id - get one *)
  | `GET, ["api"; "coupons"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Coupon_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Coupon_model.to_yojson (Coupon_model.row_to_t r) in
          respond_json 200 (apply_projection_coupon j)))

  (* PUT /api/coupons/:id - full update *)
  | `PUT, ["api"; "coupons"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_coupon j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((code, discount_type, discount_value, min_order_value), (max_uses, uses_count, valid_from, valid_until), is_active) = params in
          let upd_params = ((code, discount_type, discount_value, min_order_value), (max_uses, uses_count, valid_from, valid_until), (is_active, id)) in
          let* upd = Db.exec Coupon_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Coupon_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Coupon_model.to_yojson (Coupon_model.row_to_t r) in
                respond_json 200 (apply_projection_coupon j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* GET /api/coupons/{id}/valid - behavior is_valid *)
  | `GET, ["api"; "coupons"; id_str; "_id/valid"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_valid *)
       respond_json 204 (`Null))

  (* GET /api/coupons/{id}/applicable - behavior is_applicable_to_order *)
  | `GET, ["api"; "coupons"; id_str; "_id/applicable"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_applicable_to_order *)
       respond_json 204 (`Null))

  (* POST /api/coupons/{id}/redeem - behavior redeem *)
  | `POST, ["api"; "coupons"; id_str; "_id/redeem"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* @guard: TODO: evaluate guard condition — return 422 if not met *)
       (* TODO: implement behavior redeem *)
       respond_json 204 (`Null))

  (* POST /api/coupons/{id}/deactivate - behavior deactivate *)
  | `POST, ["api"; "coupons"; id_str; "_id/deactivate"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior deactivate *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
