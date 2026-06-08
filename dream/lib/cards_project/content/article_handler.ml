(* Dream handlers for Article *)
open Lwt.Syntax

let apply_projection_article (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "updated_at" then ("updated_at", v) else (k, v)) fields in
    let fields = List.map (fun (k, v) -> if k = "published_at" then ("published_at", v) else (k, v)) fields in
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

let validate_article (j : Yojson.Safe.t) : (unit, string list) result =
  let errors = ref [] in
  if not ((match (json_float_opt j "view_count") with Some v -> v >= 0. | None -> true)) then errors := "Article view count must not be negative" :: !errors;
  if not ((match (json_float_opt j "likes_count") with Some v -> v >= 0. | None -> true)) then errors := "Article likes count must not be negative" :: !errors;
  if not ((not ((json_string_opt j "status") = Some "Published") || ((json_present j "published_at")))) then errors := "Published article must have a published_at timestamp" :: !errors;
  if !errors = [] then Ok () else Error (List.rev !errors)

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let title = match member "title" j with `String s -> s | _ -> "" in
  let slug = match member "slug" j with `String s -> s | _ -> "" in
  let body = match member "body" j with `String s -> s | _ -> "" in
  let excerpt = match member "excerpt" j with `String s -> Some s | _ -> None in
  let cover_image_url = match member "cover_image_url" j with `String s -> Some s | _ -> None in
  let status = match member "status" j with `String s -> s | _ -> "" in
  let article_type = match member "article_type" j with `String s -> s | _ -> "" in
  let language = match member "language" j with `String s -> s | _ -> "" in
  let view_count = match member "view_count" j with `Int i -> i | _ -> 0 in
  let likes_count = match member "likes_count" j with `Int i -> i | _ -> 0 in
  let is_featured = match member "is_featured" j with `Bool b -> b | _ -> false in
  let published_at = match member "published_at" j with `String s -> Some s | _ -> None in
  let author_id = match member "author_id" j with `Int i -> i | _ -> 0 in
  let featured_deck_id = match member "featured_deck_id" j with `Int i -> Some i | _ -> None in
  ((title, slug, body, excerpt), (cover_image_url, status, article_type, language), (view_count, likes_count, is_featured, published_at), (author_id, featured_deck_id))

let handler_article (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/articles - list with optional ?q= search *)
  | `GET, ["api"; "articles"] ->
    let q = Dream.query req "q" |> Option.value ~default:"" in
    let* rows = Db.collect_list Article_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let filtered = if q = "" then items
         else List.filter (fun r ->
           let s = (Article_model.row_to_t r).title in String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false)
           || (match (Article_model.row_to_t r).excerpt with Some s -> String.length s > 0 && (try ignore (Str.search_forward (Str.regexp_string q) s 0); true with Not_found -> false) | None -> false)) items in
       let json = `List (List.map (fun r ->
         let j = Article_model.to_yojson (Article_model.row_to_t r) in
         apply_projection_article j) filtered) in
       respond_json 200 json)

  (* POST /api/articles - create *)
  | `POST, ["api"; "articles"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       (match validate_article j with
        | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
        | Ok () ->
       let params = extract_insert_params j in
       let* ins = Db.exec Article_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Article_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Article_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Article_model.to_yojson (Article_model.row_to_t r) in
                respond_json 201 (apply_projection_article j)
              | Ok None -> respond_json 404 (`String "Not found")))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/articles/:id - get one *)
  | `GET, ["api"; "articles"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Article_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Article_model.to_yojson (Article_model.row_to_t r) in
          respond_json 200 (apply_projection_article j)))

  (* PUT /api/articles/:id - full update *)
  | `PUT, ["api"; "articles"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* body = Dream.body req in
       (try
          let j = Yojson.Safe.from_string body in
          (match validate_article j with
           | Error errs -> respond_json 422 (`Assoc [("errors", `List (List.map (fun e -> `String e) errs))])
           | Ok () ->
          let params = extract_insert_params j in
          let ((title, slug, body, excerpt), (cover_image_url, status, article_type, language), (view_count, likes_count, is_featured, published_at), (author_id, featured_deck_id)) = params in
          let upd_params = ((title, slug, body, excerpt), (cover_image_url, status, article_type, language), (view_count, likes_count, is_featured, published_at), (author_id, featured_deck_id, id)) in
          let* upd = Db.exec Article_model.update_q upd_params in
          (match upd with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok () ->
             let* row = Db.find_opt Article_model.get_by_id_q id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok None -> respond_json 404 (`String "Not found")
              | Ok (Some r) ->
                let j = Article_model.to_yojson (Article_model.row_to_t r) in
                respond_json 200 (apply_projection_article j))))
       with _ -> respond_json 400 (`String "Invalid JSON")))

  (* ── Lifecycle transitions ── *)
  | `PATCH, ["api"; "articles"; id_str; "transitions"; "draft-to-published"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Article_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Article_model.row_to_t r in
          if rec_.status <> "Draft" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Published via DB *)
            respond_json 200 (`Assoc [("status", `String "Published")])))

  | `PATCH, ["api"; "articles"; id_str; "transitions"; "published-to-archived"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Article_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Article_model.row_to_t r in
          if rec_.status <> "Published" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Archived via DB *)
            respond_json 200 (`Assoc [("status", `String "Archived")])))

  | `PATCH, ["api"; "articles"; id_str; "transitions"; "archived-to-draft"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Article_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let rec_ = Article_model.row_to_t r in
          if rec_.status <> "Archived" then
            respond_json 409 (`String "Invalid transition")
          else
            (* TODO: update status to Draft via DB *)
            respond_json 200 (`Assoc [("status", `String "Draft")])))

  | `PATCH, ["api"; "articles"; id_str; "transitions"; "published-to-draft"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Article_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some _) ->
          respond_json 409 (`String "Transition Published -> Draft not allowed")))

  (* POST /api/articles/{id}/publish - behavior publish *)
  | `POST, ["api"; "articles"; id_str; "_id/publish"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior publish *)
       respond_json 204 (`Null))

  (* POST /api/articles/{id}/archive - behavior archive *)
  | `POST, ["api"; "articles"; id_str; "_id/archive"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior archive *)
       respond_json 204 (`Null))

  (* POST /api/articles/{id}/view - behavior increment_view *)
  | `POST, ["api"; "articles"; id_str; "_id/view"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior increment_view *)
       respond_json 204 (`Null))

  (* POST /api/articles/{id}/like - behavior like *)
  | `POST, ["api"; "articles"; id_str; "_id/like"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior like *)
       respond_json 204 (`Null))

  (* DELETE /api/articles/{id}/like - behavior unlike *)
  | `GET, ["api"; "articles"; id_str; "_id/like"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior unlike *)
       respond_json 204 (`Null))

  (* GET /api/articles/{id}/reading-time - behavior reading_time_minutes *)
  | `GET, ["api"; "articles"; id_str; "_id/reading-time"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior reading_time_minutes *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
