-module(player_collection_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_patch/2, handle_delete/2, delete_resource/2, handle_add/2, handle_remove/2, handle_estimated_value/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PATCH">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    Method = cowboy_req:method(Req),
    Handler = case Method of
        <<"PATCH">> -> handle_patch;
        _           -> handle_post
    end,
    {[{<<"application/json">>, Handler}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case player_collection_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(acquired_at, maps:get(acquired_at, M, undefined), maps:remove(acquired_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = player_collection_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            UserId = cowboy_req:header(<<"x-user-id">>, Req, undefined),
            OwnerId = maps:get(<<"player_id">>, State, undefined),
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
    case validate_player_collection_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = player_collection_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = player_collection_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    UserId = cowboy_req:header(<<"x-user-id">>, Req0, undefined),
    OwnerId = maps:get(<<"player_id">>, State, undefined),
    case UserId =:= (if is_integer(OwnerId) -> integer_to_binary(OwnerId); true -> OwnerId end) of
        false ->
            Req_own = cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, <<"{\"error\":\"You do not own this resource.\"}">>, Req0),
            {stop, Req_own, State};
        true ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = player_collection_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = player_collection_store:update(Updated),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    UserId = cowboy_req:header(<<"x-user-id">>, Req, undefined),
    OwnerId = maps:get(<<"player_id">>, State, undefined),
    case UserId =:= (if is_integer(OwnerId) -> integer_to_binary(OwnerId); true -> OwnerId end) of
        false ->
            Req2 = cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, <<"{\"error\":\"You do not own this resource.\"}">>, Req),
            {stop, Req2, State};
        true ->
            ok = player_collection_store:delete(maps:get(<<"id">>, State)),
            {true, Req, State}
    end.

params_to_record(Id, Params) ->
    #player_collection{
        id         = Id,
        quantity   = maps:get(<<"quantity">>, Params, 1),
        foil       = maps:get(<<"foil">>, Params, false),
        condition  = maps:get(<<"condition">>, Params, <<"Mint">>),
        acquired_at = maps:get(<<"acquired_at">>, Params, undefined),
        acquired_via = maps:get(<<"acquired_via">>, Params, <<"Purchase">>),
        player_id  = maps:get(<<"player_id">>, Params, undefined),
        card_id    = maps:get(<<"card_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #player_collection{
        id         = Record#player_collection.id,
        quantity   = maps:get(<<"quantity">>, Params, Record#player_collection.quantity),
        foil       = maps:get(<<"foil">>, Params, Record#player_collection.foil),
        condition  = maps:get(<<"condition">>, Params, Record#player_collection.condition),
        acquired_at = maps:get(<<"acquired_at">>, Params, Record#player_collection.acquired_at),
        acquired_via = maps:get(<<"acquired_via">>, Params, Record#player_collection.acquired_via),
        player_id  = maps:get(<<"player_id">>, Params, Record#player_collection.player_id),
        card_id    = maps:get(<<"card_id">>, Params, Record#player_collection.card_id),
        created_at = Record#player_collection.created_at,
        updated_at = iso_now()
    }.

record_to_map(#player_collection{id = Id, quantity = Quantity, foil = Foil, condition = Condition, acquired_at = AcquiredAt, acquired_via = AcquiredVia, player_id = PlayerId, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"quantity">> => Quantity,
        <<"foil">> => Foil,
        <<"condition">> => Condition,
        <<"acquired_at">> => AcquiredAt,
        <<"acquired_via">> => AcquiredVia,
        <<"player_id">> => PlayerId,
        <<"card_id">> => CardId,
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

validate_player_collection_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"quantity">>, M, undefined)) > 0) of false -> {true, <<"Collection quantity must be greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_add(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = add_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

add_behavior(_Record, _Params) ->
    %% TODO: implement add(quantity)
    ok.

handle_remove(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = remove_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

remove_behavior(_Record, _Params) ->
    %% TODO: implement remove(quantity)
    ok.

handle_estimated_value(Req, State) ->
    Result = estimated_value_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

estimated_value_behavior(_Record) ->
    %% TODO: implement estimated_value
    null.

