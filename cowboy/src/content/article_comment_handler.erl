-module(article_comment_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_delete/2, delete_resource/2, handle_hide/2, handle_unhide/2, handle_is_reply/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, handle_post}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case article_comment_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = article_comment_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Id     = article_comment_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = article_comment_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
.

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    ok = article_comment_store:delete(maps:get(<<"id">>, State)),
    {true, Req, State}.

params_to_record(Id, Params) ->
    #article_comment{
        id         = Id,
        body       = maps:get(<<"body">>, Params, undefined),
        is_hidden  = maps:get(<<"is_hidden">>, Params, undefined),
        article_id = maps:get(<<"article_id">>, Params, undefined),
        author_id  = maps:get(<<"author_id">>, Params, undefined),
        parent_comment_id = maps:get(<<"parent_comment_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#article_comment{id = Id, body = Body, is_hidden = IsHidden, article_id = ArticleId, author_id = AuthorId, parent_comment_id = ParentCommentId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"body">> => Body,
        <<"is_hidden">> => IsHidden,
        <<"article_id">> => ArticleId,
        <<"author_id">> => AuthorId,
        <<"parent_comment_id">> => ParentCommentId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_hide(Req, State) ->
    _ = hide_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

hide_behavior(_Record) ->
    %% TODO: implement hide
    ok.

handle_unhide(Req, State) ->
    _ = unhide_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

unhide_behavior(_Record) ->
    %% TODO: implement unhide
    ok.

handle_is_reply(Req, State) ->
    Result = is_reply_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_reply_behavior(_Record) ->
    %% TODO: implement is_reply
    null.

