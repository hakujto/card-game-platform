-module(tournament_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_start/2, handle_cancel/2, handle_complete/2, handle_generate_round/2, handle_calculate_prize_distribution/2, handle_register_player/2, handle_is_full/2, handle_transition_draft_to_registration/2, handle_transition_registration_to_ongoing/2, handle_transition_registration_to_cancelled/2, handle_transition_ongoing_to_completed/2, handle_transition_ongoing_to_cancelled/2]).

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
            case tournament_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(end_time, maps:get(end_time, M, undefined), maps:remove(end_time, M)) end)((fun(M) -> maps:put(start_time, maps:get(start_time, M, undefined), maps:remove(start_time, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map))).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = tournament_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(name, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(lists:map(fun apply_projection/1, Filtered)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_tournament_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_tournament_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = tournament_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = tournament_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = tournament_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = tournament_store:update(Updated),
    sync_season_stats_hook(Updated),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #tournament{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        description = maps:get(<<"description">>, Params, undefined),
        status     = maps:get(<<"status">>, Params, undefined),
        format     = maps:get(<<"format">>, Params, undefined),
        tournament_type = maps:get(<<"tournament_type">>, Params, undefined),
        max_players = maps:get(<<"max_players">>, Params, undefined),
        entry_fee  = maps:get(<<"entry_fee">>, Params, undefined),
        prize_pool = maps:get(<<"prize_pool">>, Params, undefined),
        start_time = maps:get(<<"start_time">>, Params, undefined),
        end_time   = maps:get(<<"end_time">>, Params, undefined),
        is_online  = maps:get(<<"is_online">>, Params, undefined),
        location   = maps:get(<<"location">>, Params, undefined),
        rules_text = maps:get(<<"rules_text">>, Params, undefined),
        season_id  = maps:get(<<"season_id">>, Params, undefined),
        organizer_id = maps:get(<<"organizer_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #tournament{
        id         = Record#tournament.id,
        name       = maps:get(<<"name">>, Params, Record#tournament.name),
        description = maps:get(<<"description">>, Params, Record#tournament.description),
        status     = maps:get(<<"status">>, Params, Record#tournament.status),
        format     = maps:get(<<"format">>, Params, Record#tournament.format),
        tournament_type = maps:get(<<"tournament_type">>, Params, Record#tournament.tournament_type),
        max_players = maps:get(<<"max_players">>, Params, Record#tournament.max_players),
        entry_fee  = maps:get(<<"entry_fee">>, Params, Record#tournament.entry_fee),
        prize_pool = maps:get(<<"prize_pool">>, Params, Record#tournament.prize_pool),
        start_time = maps:get(<<"start_time">>, Params, Record#tournament.start_time),
        end_time   = maps:get(<<"end_time">>, Params, Record#tournament.end_time),
        is_online  = maps:get(<<"is_online">>, Params, Record#tournament.is_online),
        location   = maps:get(<<"location">>, Params, Record#tournament.location),
        rules_text = maps:get(<<"rules_text">>, Params, Record#tournament.rules_text),
        season_id  = maps:get(<<"season_id">>, Params, Record#tournament.season_id),
        organizer_id = maps:get(<<"organizer_id">>, Params, Record#tournament.organizer_id),
        created_at = Record#tournament.created_at,
        updated_at = iso_now()
    }.

record_to_map(#tournament{id = Id, name = Name, description = Description, status = Status, format = Format, tournament_type = TournamentType, max_players = MaxPlayers, entry_fee = EntryFee, prize_pool = PrizePool, start_time = StartTime, end_time = EndTime, is_online = IsOnline, location = Location, rules_text = RulesText, season_id = SeasonId, organizer_id = OrganizerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"description">> => Description,
        <<"status">> => Status,
        <<"format">> => Format,
        <<"tournament_type">> => TournamentType,
        <<"max_players">> => MaxPlayers,
        <<"entry_fee">> => EntryFee,
        <<"prize_pool">> => PrizePool,
        <<"start_time">> => StartTime,
        <<"end_time">> => EndTime,
        <<"is_online">> => IsOnline,
        <<"location">> => Location,
        <<"rules_text">> => RulesText,
        <<"season_id">> => SeasonId,
        <<"organizer_id">> => OrganizerId,
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

%% ── Lifecycle hooks ──────────────────────────────────────────────────
sync_season_stats_hook(Record) ->
    %% TODO: implement sync_season_stats
    Record.

to_number(V) when is_integer(V) -> float(V);
to_number(V) when is_float(V)   -> V;
to_number(V) when is_binary(V)  ->
    try binary_to_float(V) catch _:_ -> try float(binary_to_integer(V)) catch _:_ -> 0.0 end end;
to_number(_)                    -> 0.0.

validate_tournament_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"max_players">>, M, undefined)) >= 2 andalso to_number(maps:get(<<"max_players">>, M, undefined)) =< 512) of false -> {true, <<"Tournament must allow between 2 and 512 players">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"entry_fee">>, M, undefined)) >= 0) of false -> {true, <<"Entry fee must not be negative">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"prize_pool">>, M, undefined)) >= 0) of false -> {true, <<"Prize pool must not be negative">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_tournament_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"end_time">>, M, undefined) =/= undefined andalso maps:get(<<"end_time">>, M, undefined) =/= null)) andalso not ((maps:get(<<"end_time">>, M, undefined) > maps:get(<<"start_time">>, M, undefined))) of true -> {true, <<"End time must be after start time">>}; _ -> false end end
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

handle_cancel(Req, State) ->
    _ = cancel_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

cancel_behavior(_Record) ->
    %% TODO: implement cancel
    ok.

handle_complete(Req, State) ->
    _ = complete_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

complete_behavior(_Record) ->
    %% TODO: implement complete
    ok.

handle_generate_round(Req, State) ->
    _ = generate_round_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

generate_round_behavior(_Record) ->
    %% TODO: implement generate_round
    ok.

handle_calculate_prize_distribution(Req, State) ->
    Result = calculate_prize_distribution_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

calculate_prize_distribution_behavior(_Record) ->
    %% TODO: implement calculate_prize_distribution
    null.

handle_register_player(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = register_player_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

register_player_behavior(_Record, _Params) ->
    %% TODO: implement register_player(player_id, deck_id)
    ok.

handle_is_full(Req, State) ->
    Result = is_full_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_full_behavior(_Record) ->
    %% TODO: implement is_full
    null.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_draft_to_registration(Req, State) ->
    %% Transition: Draft -> Registration
    %% @on guard: [{"type":"neq","field":"name","value":"null"},{"type":"neq","field":"start_time","value":"null"}]
    ok = tournament_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Registration">>),
    ok = tournament_store:update_field(maps:get(<<"id">>, State), status, <<"Registration">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Registration">>}), Req), State}.

handle_transition_registration_to_ongoing(Req, State) ->
    %% Transition: Registration -> Ongoing
    ok = tournament_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Ongoing">>),
    ok = tournament_store:update_field(maps:get(<<"id">>, State), status, <<"Ongoing">>),
    start_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Ongoing">>}), Req), State}.

handle_transition_registration_to_cancelled(Req, State) ->
    %% Transition: Registration -> Cancelled
    ok = tournament_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Cancelled">>),
    ok = tournament_store:update_field(maps:get(<<"id">>, State), status, <<"Cancelled">>),
    cancel_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Cancelled">>}), Req), State}.

handle_transition_ongoing_to_completed(Req, State) ->
    %% Transition: Ongoing -> Completed
    ok = tournament_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Completed">>),
    ok = tournament_store:update_field(maps:get(<<"id">>, State), status, <<"Completed">>),
    complete_behavior(State),
    calculate_prize_distribution_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Completed">>}), Req), State}.

handle_transition_ongoing_to_cancelled(Req, State) ->
    %% Transition: Ongoing -> Cancelled
    ok = tournament_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Cancelled">>),
    ok = tournament_store:update_field(maps:get(<<"id">>, State), status, <<"Cancelled">>),
    cancel_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Cancelled">>}), Req), State}.

