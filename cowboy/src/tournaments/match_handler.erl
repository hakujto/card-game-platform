-module(match_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_record_result/2, handle_finalize_result/2, handle_determine_winner/2, handle_concede/2, handle_draw/2, handle_transition_pending_to_active/2, handle_transition_active_to_completed/2, handle_transition_active_to_draw/2, handle_transition_pending_to_b_y_e/2, handle_transition_completed_to_active/2, handle_transition_draw_to_active/2, handle_transition_b_y_e_to_active/2]).

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
            case match_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(ended_at, maps:get(ended_at, M, undefined), maps:remove(ended_at, M)) end)((fun(M) -> maps:put(started_at, maps:get(started_at, M, undefined), maps:remove(started_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = match_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_match_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_match_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = match_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = match_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

params_to_record(Id, Params) ->
    #match{
        id         = Id,
        table_number = maps:get(<<"table_number">>, Params, undefined),
        status     = maps:get(<<"status">>, Params, <<"Pending">>),
        player1_wins = maps:get(<<"player1_wins">>, Params, 0),
        player2_wins = maps:get(<<"player2_wins">>, Params, 0),
        started_at = maps:get(<<"started_at">>, Params, undefined),
        ended_at   = maps:get(<<"ended_at">>, Params, undefined),
        result_notes = maps:get(<<"result_notes">>, Params, undefined),
        round_id   = maps:get(<<"round_id">>, Params, undefined),
        player1_id = maps:get(<<"player1_id">>, Params, undefined),
        player2_id = maps:get(<<"player2_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#match{id = Id, table_number = TableNumber, status = Status, player1_wins = Player1Wins, player2_wins = Player2Wins, started_at = StartedAt, ended_at = EndedAt, result_notes = ResultNotes, round_id = RoundId, player1_id = Player1Id, player2_id = Player2Id, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"table_number">> => TableNumber,
        <<"status">> => Status,
        <<"player1_wins">> => Player1Wins,
        <<"player2_wins">> => Player2Wins,
        <<"started_at">> => StartedAt,
        <<"ended_at">> => EndedAt,
        <<"result_notes">> => ResultNotes,
        <<"round_id">> => RoundId,
        <<"player1_id">> => Player1Id,
        <<"player2_id">> => Player2Id,
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

validate_match_rules(M) ->
    Checks = [
        fun() -> case ((to_number(maps:get(<<"player1_wins">>, M, undefined)) >= 0) andalso (to_number(maps:get(<<"player2_wins">>, M, undefined)) >= 0)) of false -> {true, <<"Win counts must not be negative">>}; _ -> false end end,
        fun() -> case ((to_number(maps:get(<<"player1_wins">>, M, undefined)) >= 0 andalso to_number(maps:get(<<"player1_wins">>, M, undefined)) =< 2) andalso (to_number(maps:get(<<"player2_wins">>, M, undefined)) >= 0 andalso to_number(maps:get(<<"player2_wins">>, M, undefined)) =< 2)) of false -> {true, <<"Win counts cannot exceed 2 in a best-of-3 match">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_match_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"status">>, M, undefined) =:= <<"BYE">>)) andalso not ((maps:get(<<"player2">>, M, undefined) =:= undefined orelse maps:get(<<"player2">>, M, undefined) =:= null)) of true -> {true, <<"BYE match must not have a second player">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"ended_at">>, M, undefined) =/= undefined andalso maps:get(<<"ended_at">>, M, undefined) =/= null)) andalso not ((maps:get(<<"ended_at">>, M, undefined) > maps:get(<<"started_at">>, M, undefined))) of true -> {true, <<"Match end time must be after start time">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"status">>, M, undefined) =:= <<"Completed">>)) andalso not ((maps:get(<<"started_at">>, M, undefined) =/= undefined andalso maps:get(<<"started_at">>, M, undefined) =/= null)) of true -> {true, <<"Completed match must have a start time">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_record_result(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = record_result_behavior(State, Params),
    determine_winner_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

record_result_behavior(_Record, _Params) ->
    %% TODO: implement record_result(p1_wins, p2_wins)
    ok.

handle_finalize_result(Req, State) ->
    _ = finalize_result_behavior(State),
    determine_winner_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

finalize_result_behavior(_Record) ->
    %% TODO: implement finalize_result
    ok.

handle_determine_winner(Req, State) ->
    Result = determine_winner_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

determine_winner_behavior(_Record) ->
    %% TODO: implement determine_winner
    null.

handle_concede(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case check_guard_concede(State) of
        false -> reply_422(Req1, [<<"Guard condition not met for concede">>], State);
        true  ->
    _ = concede_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}
    end.

check_guard_concede(_Record) ->
    %% TODO: evaluate guard for concede
    true.

concede_behavior(_Record, _Params) ->
    %% TODO: implement concede(player_id)
    ok.

handle_draw(Req, State) ->
    _ = draw_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

draw_behavior(_Record) ->
    %% TODO: implement draw
    ok.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_pending_to_active(Req, State) ->
    %% Transition: Pending -> Active
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"judge">>, <<"head_judge">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Pending -> Active">>}), Req), State};
        true  ->
    ok = match_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Active">>),
    ok = match_store:update_field(maps:get(<<"id">>, State), status, <<"Active">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Active">>}), Req), State}
    end.

handle_transition_active_to_completed(Req, State) ->
    %% Transition: Active -> Completed
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"judge">>, <<"head_judge">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Active -> Completed">>}), Req), State};
        true  ->
    ok = match_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Completed">>),
    ok = match_store:update_field(maps:get(<<"id">>, State), status, <<"Completed">>),
    finalize_result_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Completed">>}), Req), State}
    end.

handle_transition_active_to_draw(Req, State) ->
    %% Transition: Active -> Draw
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"judge">>, <<"head_judge">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Active -> Draw">>}), Req), State};
        true  ->
    ok = match_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Draw">>),
    ok = match_store:update_field(maps:get(<<"id">>, State), status, <<"Draw">>),
    draw_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Draw">>}), Req), State}
    end.

handle_transition_pending_to_b_y_e(Req, State) ->
    %% Transition: Pending -> BYE
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"judge">>, <<"head_judge">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Pending -> BYE">>}), Req), State};
        true  ->
    ok = match_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"BYE">>),
    ok = match_store:update_field(maps:get(<<"id">>, State), status, <<"BYE">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"BYE">>}), Req), State}
    end.

handle_transition_completed_to_active(Req, State) ->
    %% Transition: Completed -> Active
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition Completed -> Active is not allowed">>}), Req), State}.

handle_transition_draw_to_active(Req, State) ->
    %% Transition: Draw -> Active
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition Draw -> Active is not allowed">>}), Req), State}.

handle_transition_b_y_e_to_active(Req, State) ->
    %% Transition: BYE -> Active
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition BYE -> Active is not allowed">>}), Req), State}.

