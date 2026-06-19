-module(achievement_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_point_value/2, handle_reveal/2]).

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
            case achievement_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = achievement_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(name, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(Filtered),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_achievement_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = achievement_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = achievement_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = achievement_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = achievement_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #achievement{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        description = maps:get(<<"description">>, Params, undefined),
        icon_url   = maps:get(<<"icon_url">>, Params, undefined),
        points     = maps:get(<<"points">>, Params, 10),
        rarity     = maps:get(<<"rarity">>, Params, <<"Common">>),
        is_hidden  = maps:get(<<"is_hidden">>, Params, false),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #achievement{
        id         = Record#achievement.id,
        name       = maps:get(<<"name">>, Params, Record#achievement.name),
        description = maps:get(<<"description">>, Params, Record#achievement.description),
        icon_url   = maps:get(<<"icon_url">>, Params, Record#achievement.icon_url),
        points     = maps:get(<<"points">>, Params, Record#achievement.points),
        rarity     = maps:get(<<"rarity">>, Params, Record#achievement.rarity),
        is_hidden  = maps:get(<<"is_hidden">>, Params, Record#achievement.is_hidden),
        created_at = Record#achievement.created_at,
        updated_at = iso_now()
    }.

record_to_map(#achievement{id = Id, name = Name, description = Description, icon_url = IconUrl, points = Points, rarity = Rarity, is_hidden = IsHidden, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"description">> => Description,
        <<"icon_url">> => IconUrl,
        <<"points">> => Points,
        <<"rarity">> => Rarity,
        <<"is_hidden">> => IsHidden,
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

validate_achievement_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"points">>, M, undefined)) > 0) of false -> {true, <<"Achievement must award at least one point">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_point_value(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = point_value_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

point_value_behavior(_Record, _Params) ->
    %% TODO: implement point_value(multiplier)
    null.

handle_reveal(Req, State) ->
    _ = reveal_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

reveal_behavior(_Record) ->
    %% TODO: implement reveal
    ok.

