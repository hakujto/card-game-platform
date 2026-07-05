-module(season_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_activate/2, handle_deactivate/2, handle_finalize_rewards/2, handle_is_ongoing/2]).

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
            case season_store:find(binary_to_integer(Id)) of
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
            All = season_store:all(),
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
    case validate_season_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = season_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = season_store:insert(Record),
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
    {ok, ExistingRecord} = season_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = season_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #season{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        start_date = maps:get(<<"start_date">>, Params, undefined),
        end_date   = maps:get(<<"end_date">>, Params, undefined),
        format     = maps:get(<<"format">>, Params, <<"Standard">>),
        is_active  = maps:get(<<"is_active">>, Params, false),
        reward_description = maps:get(<<"reward_description">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #season{
        id         = Record#season.id,
        name       = maps:get(<<"name">>, Params, Record#season.name),
        start_date = maps:get(<<"start_date">>, Params, Record#season.start_date),
        end_date   = maps:get(<<"end_date">>, Params, Record#season.end_date),
        format     = maps:get(<<"format">>, Params, Record#season.format),
        is_active  = maps:get(<<"is_active">>, Params, Record#season.is_active),
        reward_description = maps:get(<<"reward_description">>, Params, Record#season.reward_description),
        created_at = Record#season.created_at,
        updated_at = iso_now()
    }.

record_to_map(#season{id = Id, name = Name, start_date = StartDate, end_date = EndDate, format = Format, is_active = IsActive, reward_description = RewardDescription, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"start_date">> => StartDate,
        <<"end_date">> => EndDate,
        <<"format">> => Format,
        <<"is_active">> => IsActive,
        <<"reward_description">> => RewardDescription,
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

validate_season_rules(M) ->
    Checks = [
        fun() -> case (maps:get(<<"end_date">>, M, undefined) > maps:get(<<"start_date">>, M, undefined)) of false -> {true, <<"Season end date must be after start date">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_activate(Req, State) ->
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>]) of
        false -> cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for activate">>}), Req), {stop, Req, State};
        true  ->
    _ = activate_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

activate_behavior(_Record) ->
    %% TODO: implement activate
    ok.

handle_deactivate(Req, State) ->
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>]) of
        false -> cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for deactivate">>}), Req), {stop, Req, State};
        true  ->
    _ = deactivate_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

deactivate_behavior(_Record) ->
    %% TODO: implement deactivate
    ok.

handle_finalize_rewards(Req, State) ->
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>]) of
        false -> cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for finalize_rewards">>}), Req), {stop, Req, State};
        true  ->
    _ = finalize_rewards_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

finalize_rewards_behavior(_Record) ->
    %% TODO: implement finalize_rewards
    ok.

handle_is_ongoing(Req, State) ->
    Result = is_ongoing_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_ongoing_behavior(_Record) ->
    %% TODO: implement is_ongoing
    null.

