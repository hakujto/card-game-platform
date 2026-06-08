(* Dream handlers for ArticleComment *)
open Lwt.Syntax

let apply_projection_article_comment (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | `Assoc fields ->
    let fields = List.filter (fun (k, _) -> not (List.mem k [])) fields in
    let fields = List.map (fun (k, v) -> if k = "created_at" then ("created_at", v) else (k, v)) fields in
    `Assoc fields
  | other -> other

let extract_insert_params (j : Yojson.Safe.t) =
  let open Yojson.Safe.Util in
  let body = match member "body" j with `String s -> s | _ -> "" in
  let is_hidden = match member "is_hidden" j with `Bool b -> b | _ -> false in
  let article_id = match member "article_id" j with `Int i -> i | _ -> 0 in
  let author_id = match member "author_id" j with `Int i -> i | _ -> 0 in
  let parent_comment_id = match member "parent_comment_id" j with `Int i -> Some i | _ -> None in
  ((body, is_hidden, article_id, author_id), parent_comment_id)

let handler_article_comment (db : (module Caqti_lwt.CONNECTION)) req =
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

  (* GET /api/article_comments - list all *)
  | `GET, ["api"; "article_comments"] ->
    let* rows = Db.collect_list Article_comment_model.get_all_q () in
    (match rows with
     | Error e -> respond_json 500 (`String (Caqti_error.show e))
     | Ok items ->
       let json = `List (List.map (fun r ->
         let j = Article_comment_model.to_yojson (Article_comment_model.row_to_t r) in
         apply_projection_article_comment j) items) in
       respond_json 200 json)

  (* POST /api/article_comments - create *)
  | `POST, ["api"; "article_comments"] ->
    let* body = Dream.body req in
    (try
       let j = Yojson.Safe.from_string body in
       let params = extract_insert_params j in
       let* ins = Db.exec Article_comment_model.insert_q params in
       (match ins with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () ->
          let* last_id = Db.find Article_comment_model.last_id_q () in
          (match last_id with
           | Error e -> respond_json 500 (`String (Caqti_error.show e))
           | Ok new_id ->
             let* row = Db.find_opt Article_comment_model.get_by_id_q new_id in
             (match row with
              | Error e -> respond_json 500 (`String (Caqti_error.show e))
              | Ok (Some r) ->
                let j = Article_comment_model.to_yojson (Article_comment_model.row_to_t r) in
                respond_json 201 (apply_projection_article_comment j)
              | Ok None -> respond_json 404 (`String "Not found"))))
     with _ -> respond_json 400 (`String "Invalid JSON"))

  (* GET /api/article_comments/:id - get one *)
  | `GET, ["api"; "article_comments"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* row = Db.find_opt Article_comment_model.get_by_id_q id in
       (match row with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok None -> respond_json 404 (`String "Not found")
        | Ok (Some r) ->
          let j = Article_comment_model.to_yojson (Article_comment_model.row_to_t r) in
          respond_json 200 (apply_projection_article_comment j)))

  (* DELETE /api/article_comments/:id *)
  | `DELETE, ["api"; "article_comments"; id_str] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some id ->
       let* del = Db.exec Article_comment_model.delete_q id in
       (match del with
        | Error e -> respond_json 500 (`String (Caqti_error.show e))
        | Ok () -> Dream.respond ~status:`No_Content ""))

  (* POST /api/comments/{id}/hide - behavior hide *)
  | `POST, ["api"; "article_comments"; id_str; "_id/hide"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior hide *)
       respond_json 204 (`Null))

  (* POST /api/comments/{id}/unhide - behavior unhide *)
  | `POST, ["api"; "article_comments"; id_str; "_id/unhide"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior unhide *)
       respond_json 204 (`Null))

  (* GET /api/comments/{id}/is-reply - behavior is_reply *)
  | `GET, ["api"; "article_comments"; id_str; "_id/is-reply"] ->
    (match int_of_string_opt id_str with
     | None -> respond_json 400 (`String "Invalid id")
     | Some _id ->
       (* TODO: implement behavior is_reply *)
       respond_json 204 (`Null))

  | _ -> respond_json 404 (`String "Not found")
