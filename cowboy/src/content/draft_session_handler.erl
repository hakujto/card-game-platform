-module(draft_session_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_start/2, handle_abandon/2, handle_complete/2, handle_is_full/2, handle_transition_waiting_for_players_to_drafting/2, handle_transition_drafting_to_completed/2, handle_transition_drafting_to_abandoned/2, handle_transition_waiting_for_players_to_abandoned/2]).

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
            case draft_session_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(completed_at, maps:get(completed_at, M, undefined), maps:remove(completed_at, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = draft_session_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_draft_session_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_draft_session_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = draft_session_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = draft_session_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

params_to_record(Id, Params) ->
    #draft_session{
        id         = Id,
        status     = maps:get(<<"status">>, Params, undefined),
        draft_type = maps:get(<<"draft_type">>, Params, undefined),
        seats      = maps:get(<<"seats">>, Params, undefined),
        time_per_pick_seconds = maps:get(<<"time_per_pick_seconds">>, Params, undefined),
        completed_at = maps:get(<<"completed_at">>, Params, undefined),
        card_set_id = maps:get(<<"card_set_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#draft_session{id = Id, status = Status, draft_type = DraftType, seats = Seats, time_per_pick_seconds = TimePerPickSeconds, completed_at = CompletedAt, card_set_id = CardSetId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"draft_type">> => DraftType,
        <<"seats">> => Seats,
        <<"time_per_pick_seconds">> => TimePerPickSeconds,
        <<"completed_at">> => CompletedAt,
        <<"card_set_id">> => CardSetId,
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

validate_draft_session_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"seats">>, M, undefined)) >= 2 andalso to_number(maps:get(<<"seats">>, M, undefined)) =< 16) of false -> {true, <<"Draft session must have between 2 and 16 seats">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"time_per_pick_seconds">>, M, undefined)) > 0) of false -> {true, <<"Time per pick must be greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_draft_session_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"completed_at">>, M, undefined) =/= undefined andalso maps:get(<<"completed_at">>, M, undefined) =/= null)) andalso not ((maps:get(<<"status">>, M, undefined) =:= <<"Completed">>)) of true -> {true, <<"completed_at can only be set when draft status is Completed">>}; _ -> false end end
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

handle_abandon(Req, State) ->
    _ = abandon_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

abandon_behavior(_Record) ->
    %% TODO: implement abandon
    ok.

handle_complete(Req, State) ->
    _ = complete_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

complete_behavior(_Record) ->
    %% TODO: implement complete
    ok.

handle_is_full(Req, State) ->
    Result = is_full_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_full_behavior(_Record) ->
    %% TODO: implement is_full
    null.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_waiting_for_players_to_drafting(Req, State) ->
    %% Transition: WaitingForPlayers -> Drafting
    ok = draft_session_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Drafting">>),
    ok = draft_session_store:update_field(maps:get(<<"id">>, State), status, <<"Drafting">>),
    start_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Drafting">>}), Req), State}.

handle_transition_drafting_to_completed(Req, State) ->
    %% Transition: Drafting -> Completed
    ok = draft_session_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Completed">>),
    ok = draft_session_store:update_field(maps:get(<<"id">>, State), status, <<"Completed">>),
    complete_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Completed">>}), Req), State}.

handle_transition_drafting_to_abandoned(Req, State) ->
    %% Transition: Drafting -> Abandoned
    ok = draft_session_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Abandoned">>),
    ok = draft_session_store:update_field(maps:get(<<"id">>, State), status, <<"Abandoned">>),
    abandon_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Abandoned">>}), Req), State}.

handle_transition_waiting_for_players_to_abandoned(Req, State) ->
    %% Transition: WaitingForPlayers -> Abandoned
    ok = draft_session_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Abandoned">>),
    ok = draft_session_store:update_field(maps:get(<<"id">>, State), status, <<"Abandoned">>),
    abandon_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Abandoned">>}), Req), State}.

