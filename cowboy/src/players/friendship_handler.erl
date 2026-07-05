-module(friendship_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_delete/2, delete_resource/2, handle_accept/2, handle_decline/2, handle_block/2]).

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
            case friendship_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = friendship_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            UserId = cowboy_req:header(<<"x-user-id">>, Req, undefined),
            OwnerId = maps:get(<<"requester_id">>, State, undefined),
            case UserId =:= (if is_integer(OwnerId) -> integer_to_binary(OwnerId); true -> OwnerId end) of
                false ->
                    Req2 = cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, <<"{\"error\":\"You do not own this resource.\"}">>, Req),
                    {stop, Req2, State};
                true ->
                    Body = jsone:encode(apply_projection(State)),
                    {Body, Req, State}
            end
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Id     = friendship_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = friendship_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
.

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    UserId = cowboy_req:header(<<"x-user-id">>, Req, undefined),
    OwnerId = maps:get(<<"requester_id">>, State, undefined),
    case UserId =:= (if is_integer(OwnerId) -> integer_to_binary(OwnerId); true -> OwnerId end) of
        false ->
            Req2 = cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, <<"{\"error\":\"You do not own this resource.\"}">>, Req),
            {stop, Req2, State};
        true ->
            ok = friendship_store:delete(maps:get(<<"id">>, State)),
            {true, Req, State}
    end.

params_to_record(Id, Params) ->
    #friendship{
        id         = Id,
        status     = maps:get(<<"status">>, Params, <<"Pending">>),
        requester_id = maps:get(<<"requester_id">>, Params, undefined),
        receiver_id = maps:get(<<"receiver_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#friendship{id = Id, status = Status, requester_id = RequesterId, receiver_id = ReceiverId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"requester_id">> => RequesterId,
        <<"receiver_id">> => ReceiverId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_accept(Req, State) ->
    _ = accept_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

accept_behavior(_Record) ->
    %% TODO: implement accept
    ok.

handle_decline(Req, State) ->
    _ = decline_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

decline_behavior(_Record) ->
    %% TODO: implement decline
    ok.

handle_block(Req, State) ->
    _ = block_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

block_behavior(_Record) ->
    %% TODO: implement block
    ok.

