(* Dream handlers for CardPriceHistory *)
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

let validate_card_price_history (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not (((match (json_float_opt j "min_price") with Some v -> v <= (Option.value (json_float_opt j "avg_price") ~default:0.) | None -> true) && (match (json_float_opt j "avg_price") with Some v -> v <= (Option.value (json_float_opt j "max_price") ~default:0.) | None -> true))) then errors := "min_price <= avg_price <= max_price must hold" :: !errors;
  if not ((match (json_float_opt j "volume") with Some v -> v >= 0. | None -> true)) then errors := "Price history volume must not be negative" :: !errors;
  if not ((match (json_float_opt j "min_price") with Some v -> v >= 0. | None -> true)) then errors := "Prices must not be negative" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let price_date = match member "price_date" j with `String s -> s | _ -> "" in
  let avg_price = match member "avg_price" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let min_price = match member "min_price" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let max_price = match member "max_price" j with `Float f -> f | `Int i -> float_of_int i | _ -> 0. in
  let volume = match member "volume" j with `Int i -> i | _ -> 0 in
  let foil = match member "foil" j with `Bool b -> b | _ -> false in
  let card_id = match member "card_id" j with `Int i -> i | _ -> 0 in
  ((price_date, avg_price, min_price, max_price), (volume, foil, card_id))

let handler_card_price_history (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/card_price_histories - list all *)
  | `GET, ["api"; "card_price_histories"] ->
    let* rows = Db.collect_list Card_price_history_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Card_price_history_model.to_yojson (Card_price_history_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* GET /api/card_price_histories/:id - get one *)
  | `GET, ["api"; "card_price_histories"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Card_price_history_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Card_price_history_model.to_yojson (Card_price_history_model.row_to_t r) in
          respond_json 200 (j)))

  (* GET /api/price-history/{id}/change - behavior price_change_percent *)
  | `GET, ["api"; "card_price_histories"; id_str; "_id/change"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior price_change_percent *)
       respond_json 204 (`Null))

  (* GET /api/price-history/{id}/spike - behavior is_price_spike *)
  | `GET, ["api"; "card_price_histories"; id_str; "_id/spike"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_price_spike *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
