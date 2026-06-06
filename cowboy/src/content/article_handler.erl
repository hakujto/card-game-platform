-module(article_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_publish/2, handle_archive/2, handle_increment_view/2, handle_like/2, handle_unlike/2, handle_reading_time_minutes/2, handle_transition_draft_to_published/2, handle_transition_published_to_archived/2, handle_transition_archived_to_draft/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PUT">>, <<"PATCH">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    Method = cowboy_req:method(Req),
    Handler = case Method of
        <<"PUT">>   -> handle_put;
        <<"PATCH">> -> handle_patch;
        _           -> handle_post
    end,
    {[{<<"application/json">>, Handler}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case article_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(published_at, maps:get(published_at, M, undefined), maps:remove(published_at, M)) end)((fun(M) -> maps:put(updated_at, maps:get(updated_at, M, undefined), maps:remove(updated_at, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map))).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = article_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(title, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(lists:map(fun apply_projection/1, Filtered)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_article_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_article_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = article_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = article_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = article_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = article_store:update(Updated),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #article{
        id         = Id,
        title      = maps:get(<<"title">>, Params, undefined),
        slug       = maps:get(<<"slug">>, Params, undefined),
        body       = maps:get(<<"body">>, Params, undefined),
        excerpt    = maps:get(<<"excerpt">>, Params, undefined),
        cover_image_url = maps:get(<<"cover_image_url">>, Params, undefined),
        status     = maps:get(<<"status">>, Params, undefined),
        article_type = maps:get(<<"article_type">>, Params, undefined),
        language   = maps:get(<<"language">>, Params, undefined),
        view_count = maps:get(<<"view_count">>, Params, undefined),
        likes_count = maps:get(<<"likes_count">>, Params, undefined),
        is_featured = maps:get(<<"is_featured">>, Params, undefined),
        published_at = maps:get(<<"published_at">>, Params, undefined),
        author_id  = maps:get(<<"author_id">>, Params, undefined),
        featured_deck_id = maps:get(<<"featured_deck_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #article{
        id         = Record#article.id,
        title      = maps:get(<<"title">>, Params, Record#article.title),
        slug       = maps:get(<<"slug">>, Params, Record#article.slug),
        body       = maps:get(<<"body">>, Params, Record#article.body),
        excerpt    = maps:get(<<"excerpt">>, Params, Record#article.excerpt),
        cover_image_url = maps:get(<<"cover_image_url">>, Params, Record#article.cover_image_url),
        status     = maps:get(<<"status">>, Params, Record#article.status),
        article_type = maps:get(<<"article_type">>, Params, Record#article.article_type),
        language   = maps:get(<<"language">>, Params, Record#article.language),
        view_count = maps:get(<<"view_count">>, Params, Record#article.view_count),
        likes_count = maps:get(<<"likes_count">>, Params, Record#article.likes_count),
        is_featured = maps:get(<<"is_featured">>, Params, Record#article.is_featured),
        published_at = maps:get(<<"published_at">>, Params, Record#article.published_at),
        author_id  = maps:get(<<"author_id">>, Params, Record#article.author_id),
        featured_deck_id = maps:get(<<"featured_deck_id">>, Params, Record#article.featured_deck_id),
        created_at = Record#article.created_at,
        updated_at = iso_now()
    }.

record_to_map(#article{id = Id, title = Title, slug = Slug, body = Body, excerpt = Excerpt, cover_image_url = CoverImageUrl, status = Status, article_type = ArticleType, language = Language, view_count = ViewCount, likes_count = LikesCount, is_featured = IsFeatured, published_at = PublishedAt, author_id = AuthorId, featured_deck_id = FeaturedDeckId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"title">> => Title,
        <<"slug">> => Slug,
        <<"body">> => Body,
        <<"excerpt">> => Excerpt,
        <<"cover_image_url">> => CoverImageUrl,
        <<"status">> => Status,
        <<"article_type">> => ArticleType,
        <<"language">> => Language,
        <<"view_count">> => ViewCount,
        <<"likes_count">> => LikesCount,
        <<"is_featured">> => IsFeatured,
        <<"published_at">> => PublishedAt,
        <<"author_id">> => AuthorId,
        <<"featured_deck_id">> => FeaturedDeckId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

reply_422(Req, Errors, State) ->
    Body = jsone:encode(#{<<"errors">> => Errors}),
    Req2 = cowboy_req:reply(422, #{<<"content-type">> => <<"application/json">>}, Body, Req),
    {stop, Req2, State}.

to_number(V) when is_integer(V) -> float(V);
to_number(V) when is_float(V)   -> V;
to_number(V) when is_binary(V)  ->
    try binary_to_float(V) catch _:_ -> try float(binary_to_integer(V)) catch _:_ -> 0.0 end end;
to_number(_)                    -> 0.0.

validate_article_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"view_count">>, M, undefined)) >= 0) of false -> {true, <<"Article view count must not be negative">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"likes_count">>, M, undefined)) >= 0) of false -> {true, <<"Article likes count must not be negative">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_article_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"status">>, M, undefined) =:= <<"Published">>)) andalso not ((maps:get(<<"published_at">>, M, undefined) =/= undefined andalso maps:get(<<"published_at">>, M, undefined) =/= null)) of true -> {true, <<"Published article must have a published_at timestamp">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_publish(Req, State) ->
    _ = publish_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

publish_behavior(_Record) ->
    %% TODO: implement publish
    ok.

handle_archive(Req, State) ->
    _ = archive_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

archive_behavior(_Record) ->
    %% TODO: implement archive
    ok.

handle_increment_view(Req, State) ->
    _ = increment_view_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

increment_view_behavior(_Record) ->
    %% TODO: implement increment_view
    ok.

handle_like(Req, State) ->
    _ = like_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

like_behavior(_Record) ->
    %% TODO: implement like
    ok.

handle_unlike(Req, State) ->
    _ = unlike_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

unlike_behavior(_Record) ->
    %% TODO: implement unlike
    ok.

handle_reading_time_minutes(Req, State) ->
    Result = reading_time_minutes_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

reading_time_minutes_behavior(_Record) ->
    %% TODO: implement reading_time_minutes
    null.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_draft_to_published(Req, State) ->
    %% Transition: Draft -> Published
    %% @on guard: [{"type":"neq","field":"title","value":"null"},{"type":"neq","field":"body","value":"null"}]
    ok = article_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Published">>),
    ok = article_store:update_field(maps:get(<<"id">>, State), status, <<"Published">>),
    publish_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Published">>}), Req), State}.

handle_transition_published_to_archived(Req, State) ->
    %% Transition: Published -> Archived
    ok = article_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Archived">>),
    ok = article_store:update_field(maps:get(<<"id">>, State), status, <<"Archived">>),
    archive_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Archived">>}), Req), State}.

handle_transition_archived_to_draft(Req, State) ->
    %% Transition: Archived -> Draft
    ok = article_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Draft">>),
    ok = article_store:update_field(maps:get(<<"id">>, State), status, <<"Draft">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Draft">>}), Req), State}.

