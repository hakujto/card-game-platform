-module(tournament_round_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_start/2, handle_complete/2, handle_generate_pairings/2, handle_is_time_expired/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, handle_post}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case tournament_round_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(ended_at, maps:get(ended_at, M, undefined), maps:remove(ended_at, M)) end)((fun(M) -> maps:put(started_at, maps:get(started_at, M, undefined), maps:remove(started_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = tournament_round_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_tournament_round_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_tournament_round_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = tournament_round_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = tournament_round_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

params_to_record(Id, Params) ->
    #tournament_round{
        id         = Id,
        round_number = maps:get(<<"round_number">>, Params, undefined),
        status     = maps:get(<<"status">>, Params, undefined),
        started_at = maps:get(<<"started_at">>, Params, undefined),
        ended_at   = maps:get(<<"ended_at">>, Params, undefined),
        time_limit_minutes = maps:get(<<"time_limit_minutes">>, Params, undefined),
        tournament_id = maps:get(<<"tournament_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#tournament_round{id = Id, round_number = RoundNumber, status = Status, started_at = StartedAt, ended_at = EndedAt, time_limit_minutes = TimeLimitMinutes, tournament_id = TournamentId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"round_number">> => RoundNumber,
        <<"status">> => Status,
        <<"started_at">> => StartedAt,
        <<"ended_at">> => EndedAt,
        <<"time_limit_minutes">> => TimeLimitMinutes,
        <<"tournament_id">> => TournamentId,
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

validate_tournament_round_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"round_number">>, M, undefined)) > 0) of false -> {true, <<"Round number must be greater than zero">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"time_limit_minutes">>, M, undefined)) > 0) of false -> {true, <<"Round time limit must be greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_tournament_round_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"ended_at">>, M, undefined) =/= undefined andalso maps:get(<<"ended_at">>, M, undefined) =/= null)) andalso not ((maps:get(<<"ended_at">>, M, undefined) > maps:get(<<"started_at">>, M, undefined))) of true -> {true, <<"Round end time must be after start time">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"status">>, M, undefined) =:= <<"Completed">>)) andalso not ((maps:get(<<"started_at">>, M, undefined) =/= undefined andalso maps:get(<<"started_at">>, M, undefined) =/= null)) of true -> {true, <<"Completed round must have a start time">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_start(Req, State) ->
    _ = start_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

start_behavior(_Record) ->
    %% TODO: implement start
    ok.

handle_complete(Req, State) ->
    _ = complete_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

complete_behavior(_Record) ->
    %% TODO: implement complete
    ok.

handle_generate_pairings(Req, State) ->
    _ = generate_pairings_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

generate_pairings_behavior(_Record) ->
    %% TODO: implement generate_pairings
    ok.

handle_is_time_expired(Req, State) ->
    Result = is_time_expired_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_time_expired_behavior(_Record) ->
    %% TODO: implement is_time_expired
    null.

