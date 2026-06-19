-module(card_ability_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_delete/2, delete_resource/2, handle_is_usable_at/2, handle_describe/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PUT">>, <<"PATCH">>, <<"DELETE">>], Req, State}.

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
            case card_ability_store:find(binary_to_integer(Id)) of
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
            All = card_ability_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(keyword, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(Filtered),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_card_ability_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = card_ability_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = card_ability_store:insert(Record),
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
    {ok, ExistingRecord} = card_ability_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = card_ability_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    ok = card_ability_store:delete(maps:get(<<"id">>, State)),
    {true, Req, State}.

params_to_record(Id, Params) ->
    #card_ability{
        id         = Id,
        ability_type = maps:get(<<"ability_type">>, Params, <<"Keyword">>),
        keyword    = maps:get(<<"keyword">>, Params, undefined),
        ability_text = maps:get(<<"ability_text">>, Params, undefined),
        timing     = maps:get(<<"timing">>, Params, undefined),
        card_id    = maps:get(<<"card_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #card_ability{
        id         = Record#card_ability.id,
        ability_type = maps:get(<<"ability_type">>, Params, Record#card_ability.ability_type),
        keyword    = maps:get(<<"keyword">>, Params, Record#card_ability.keyword),
        ability_text = maps:get(<<"ability_text">>, Params, Record#card_ability.ability_text),
        timing     = maps:get(<<"timing">>, Params, Record#card_ability.timing),
        card_id    = maps:get(<<"card_id">>, Params, Record#card_ability.card_id),
        created_at = Record#card_ability.created_at,
        updated_at = iso_now()
    }.

record_to_map(#card_ability{id = Id, ability_type = AbilityType, keyword = Keyword, ability_text = AbilityText, timing = Timing, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"ability_type">> => AbilityType,
        <<"keyword">> => Keyword,
        <<"ability_text">> => AbilityText,
        <<"timing">> => Timing,
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

validate_card_ability_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"ability_type">>, M, undefined) =:= <<"Keyword">>)) andalso not ((maps:get(<<"keyword">>, M, undefined) =/= undefined andalso maps:get(<<"keyword">>, M, undefined) =/= null)) of true -> {true, <<"Keyword ability must have a keyword name">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_is_usable_at(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = is_usable_at_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

is_usable_at_behavior(_Record, _Params) ->
    %% TODO: implement is_usable_at(timing)
    null.

handle_describe(Req, State) ->
    Result = describe_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

describe_behavior(_Record) ->
    %% TODO: implement describe
    null.

