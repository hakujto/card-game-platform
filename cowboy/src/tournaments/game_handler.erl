-module(game_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_record_winner/2, handle_duration_minutes/2]).

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
            case game_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = game_store:all(),
            Body = jsone:encode(All),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_game_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_game_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_game_fields(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = game_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = game_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end end
.

params_to_record(Id, Params) ->
    #game{
        id         = Id,
        game_number = maps:get(<<"game_number">>, Params, undefined),
        winner_side = maps:get(<<"winner_side">>, Params, undefined),
        complexity_score = maps:get(<<"complexity_score">>, Params, undefined),
        turns_played = maps:get(<<"turns_played">>, Params, undefined),
        duration_seconds = maps:get(<<"duration_seconds">>, Params, undefined),
        ended_by   = maps:get(<<"ended_by">>, Params, undefined),
        replay_url = maps:get(<<"replay_url">>, Params, undefined),
        match_id   = maps:get(<<"match_id">>, Params, undefined),
        winner_id  = maps:get(<<"winner_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#game{id = Id, game_number = GameNumber, winner_side = WinnerSide, complexity_score = ComplexityScore, turns_played = TurnsPlayed, duration_seconds = DurationSeconds, ended_by = EndedBy, replay_url = ReplayUrl, match_id = MatchId, winner_id = WinnerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"game_number">> => GameNumber,
        <<"winner_side">> => WinnerSide,
        <<"complexity_score">> => ComplexityScore,
        <<"turns_played">> => TurnsPlayed,
        <<"duration_seconds">> => DurationSeconds,
        <<"ended_by">> => EndedBy,
        <<"replay_url">> => ReplayUrl,
        <<"match_id">> => MatchId,
        <<"winner_id">> => WinnerId,
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

validate_game_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"game_number">>, M, undefined)) >= 1 andalso to_number(maps:get(<<"game_number">>, M, undefined)) =< 3) of false -> {true, <<"Game number must be between 1 and 3 (best-of-3)">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_game_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"turns_played">>, M, undefined) =/= undefined andalso maps:get(<<"turns_played">>, M, undefined) =/= null)) andalso not ((to_number(maps:get(<<"turns_played">>, M, undefined)) > 0)) of true -> {true, <<"Turns played must be greater than zero">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"duration_seconds">>, M, undefined) =/= undefined andalso maps:get(<<"duration_seconds">>, M, undefined) =/= null)) andalso not ((to_number(maps:get(<<"duration_seconds">>, M, undefined)) > 0)) of true -> {true, <<"Game duration must be greater than zero">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"winner_side">>, M, undefined) =:= <<"Draw">>)) andalso not ((maps:get(<<"winner">>, M, undefined) =:= undefined orelse maps:get(<<"winner">>, M, undefined) =:= null)) of true -> {true, <<"A draw cannot have a winner">>}; _ -> false end end,
        fun() -> case (((maps:get(<<"winner_side">>, M, undefined) =/= undefined andalso maps:get(<<"winner_side">>, M, undefined) =/= null) andalso (maps:get(<<"winner_side">>, M, undefined) =/= <<"Draw">>))) andalso not ((maps:get(<<"winner">>, M, undefined) =/= undefined andalso maps:get(<<"winner">>, M, undefined) =/= null)) of true -> {true, <<"A decisive game must have a winner player set">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_game_fields(M) ->
    Checks = [
        fun() -> case maps:get(<<"game_number">>, M, undefined) of V when is_number(V), V < 1 -> {true, <<"game_number must be >= 1">>}; _ -> false end end,
        fun() -> case maps:get(<<"game_number">>, M, undefined) of V when is_number(V), V > 3 -> {true, <<"game_number must be <= 3">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_record_winner(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = record_winner_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

record_winner_behavior(_Record, _Params) ->
    %% TODO: implement record_winner(winner_side)
    ok.

handle_duration_minutes(Req, State) ->
    Result = duration_minutes_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

duration_minutes_behavior(_Record) ->
    %% TODO: implement duration_minutes
    null.

