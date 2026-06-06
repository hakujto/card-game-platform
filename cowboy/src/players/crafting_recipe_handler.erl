-module(crafting_recipe_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_can_craft/2, handle_execute_craft/2, handle_disable/2, handle_enable/2]).

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
            case crafting_recipe_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = crafting_recipe_store:all(),
            Body = jsone:encode(All),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_crafting_recipe_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = crafting_recipe_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = crafting_recipe_store:insert(Record),
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
    {ok, ExistingRecord} = crafting_recipe_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = crafting_recipe_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #crafting_recipe{
        id         = Id,
        dust_cost  = maps:get(<<"dust_cost">>, Params, undefined),
        is_available = maps:get(<<"is_available">>, Params, undefined),
        result_card_id = maps:get(<<"result_card_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #crafting_recipe{
        id         = Record#crafting_recipe.id,
        dust_cost  = maps:get(<<"dust_cost">>, Params, Record#crafting_recipe.dust_cost),
        is_available = maps:get(<<"is_available">>, Params, Record#crafting_recipe.is_available),
        result_card_id = maps:get(<<"result_card_id">>, Params, Record#crafting_recipe.result_card_id),
        created_at = Record#crafting_recipe.created_at,
        updated_at = iso_now()
    }.

record_to_map(#crafting_recipe{id = Id, dust_cost = DustCost, is_available = IsAvailable, result_card_id = ResultCardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"dust_cost">> => DustCost,
        <<"is_available">> => IsAvailable,
        <<"result_card_id">> => ResultCardId,
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

validate_crafting_recipe_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"dust_cost">>, M, undefined)) > 0) of false -> {true, <<"Crafting recipe must have a dust cost greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_can_craft(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = can_craft_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

can_craft_behavior(_Record, _Params) ->
    %% TODO: implement can_craft(player_id)
    null.

handle_execute_craft(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = execute_craft_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

execute_craft_behavior(_Record, _Params) ->
    %% TODO: implement execute_craft(player_id)
    ok.

handle_disable(Req, State) ->
    _ = disable_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

disable_behavior(_Record) ->
    %% TODO: implement disable
    ok.

handle_enable(Req, State) ->
    _ = enable_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

enable_behavior(_Record) ->
    %% TODO: implement enable
    ok.

