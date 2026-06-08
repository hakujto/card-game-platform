(* Dream handlers for CraftingRecipe *)
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

let validate_crafting_recipe (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "dust_cost") with Some v -> v > 0. | None -> true)) then errors := "Crafting recipe must have a dust cost greater than zero" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let dust_cost = match member "dust_cost" j with `Int i -> i | _ -> 0 in
  let is_available = match member "is_available" j with `Bool b -> b | _ -> false in
  let result_card_id = match member "result_card_id" j with `Int i -> i | _ -> 0 in
  (dust_cost, is_available, result_card_id)

let handler_crafting_recipe (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/crafting_recipes - list all *)
  | `GET, ["api"; "crafting_recipes"] ->
    let* rows = Db.collect_list Crafting_recipe_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Crafting_recipe_model.to_yojson (Crafting_recipe_model.row_to_t r) in
         j) items) in
       respond_json 200 json)

  (* POST /api/crafting_recipes - create *)
  | `POST, ["api"; "crafting_recipes"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_crafting_recipe j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Crafting_recipe_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Crafting_recipe_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Crafting_recipe_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Crafting_recipe_model.to_yojson (Crafting_recipe_model.row_to_t r) in
                respond_json 201 (j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/crafting_recipes/:id - get one *)
  | `GET, ["api"; "crafting_recipes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Crafting_recipe_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Crafting_recipe_model.to_yojson (Crafting_recipe_model.row_to_t r) in
          respond_json 200 (j)))

  (* PUT /api/crafting_recipes/:id - full update *)
  | `PUT, ["api"; "crafting_recipes"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_crafting_recipe j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let (dust_cost, is_available, result_card_id) = params in
          let upd_params = (dust_cost, is_available, result_card_id, id) in
          let* upd = Db.exec Crafting_recipe_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Crafting_recipe_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Crafting_recipe_model.to_yojson (Crafting_recipe_model.row_to_t r) in
                respond_json 200 (j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* GET /api/crafting-recipes/{id}/can-craft - behavior can_craft *)
  | `GET, ["api"; "crafting_recipes"; id_str; "_id/can-craft"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior can_craft *)
       respond_json 204 (`Null))

  (* POST /api/crafting-recipes/{id}/craft - behavior execute_craft *)
  | `POST, ["api"; "crafting_recipes"; id_str; "_id/craft"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior execute_craft *)
       respond_json 204 (`Null))

  (* POST /api/crafting-recipes/{id}/disable - behavior disable *)
  | `POST, ["api"; "crafting_recipes"; id_str; "_id/disable"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior disable *)
       respond_json 204 (`Null))

  (* POST /api/crafting-recipes/{id}/enable - behavior enable *)
  | `POST, ["api"; "crafting_recipes"; id_str; "_id/enable"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior enable *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
