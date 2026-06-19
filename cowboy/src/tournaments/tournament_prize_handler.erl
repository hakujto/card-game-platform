-module(tournament_prize_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_delete/2, delete_resource/2, handle_applies_to_placement/2, handle_award_to_player/2]).

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
            case tournament_prize_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = tournament_prize_store:all(),
            Body = jsone:encode(All),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_tournament_prize_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = tournament_prize_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = tournament_prize_store:insert(Record),
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
    {ok, ExistingRecord} = tournament_prize_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = tournament_prize_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    ok = tournament_prize_store:delete(maps:get(<<"id">>, State)),
    {true, Req, State}.

params_to_record(Id, Params) ->
    #tournament_prize{
        id         = Id,
        placement_from = maps:get(<<"placement_from">>, Params, undefined),
        placement_to = maps:get(<<"placement_to">>, Params, undefined),
        prize_type = maps:get(<<"prize_type">>, Params, undefined),
        amount     = maps:get(<<"amount">>, Params, 0),
        description = maps:get(<<"description">>, Params, undefined),
        packs_count = maps:get(<<"packs_count">>, Params, undefined),
        season_points = maps:get(<<"season_points">>, Params, 0),
        tournament_id = maps:get(<<"tournament_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #tournament_prize{
        id         = Record#tournament_prize.id,
        placement_from = maps:get(<<"placement_from">>, Params, Record#tournament_prize.placement_from),
        placement_to = maps:get(<<"placement_to">>, Params, Record#tournament_prize.placement_to),
        prize_type = maps:get(<<"prize_type">>, Params, Record#tournament_prize.prize_type),
        amount     = maps:get(<<"amount">>, Params, Record#tournament_prize.amount),
        description = maps:get(<<"description">>, Params, Record#tournament_prize.description),
        packs_count = maps:get(<<"packs_count">>, Params, Record#tournament_prize.packs_count),
        season_points = maps:get(<<"season_points">>, Params, Record#tournament_prize.season_points),
        tournament_id = maps:get(<<"tournament_id">>, Params, Record#tournament_prize.tournament_id),
        created_at = Record#tournament_prize.created_at,
        updated_at = iso_now()
    }.

record_to_map(#tournament_prize{id = Id, placement_from = PlacementFrom, placement_to = PlacementTo, prize_type = PrizeType, amount = Amount, description = Description, packs_count = PacksCount, season_points = SeasonPoints, tournament_id = TournamentId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"placement_from">> => PlacementFrom,
        <<"placement_to">> => PlacementTo,
        <<"prize_type">> => PrizeType,
        <<"amount">> => Amount,
        <<"description">> => Description,
        <<"packs_count">> => PacksCount,
        <<"season_points">> => SeasonPoints,
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

validate_tournament_prize_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"placement_to">>, M, undefined)) >= to_number(maps:get(<<"placement_from">>, M, undefined))) of false -> {true, <<"placement_to must be greater than or equal to placement_from">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"placement_from">>, M, undefined)) > 0) of false -> {true, <<"placement_from must be greater than zero">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"amount">>, M, undefined)) >= 0) of false -> {true, <<"Prize amount must not be negative">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_applies_to_placement(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = applies_to_placement_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

applies_to_placement_behavior(_Record, _Params) ->
    %% TODO: implement applies_to_placement(placement)
    null.

handle_award_to_player(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = award_to_player_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

award_to_player_behavior(_Record, _Params) ->
    %% TODO: implement award_to_player(player_id)
    ok.

