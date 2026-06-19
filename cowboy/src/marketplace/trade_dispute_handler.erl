-module(trade_dispute_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_escalate/2, handle_resolve/2, handle_close_resolved/2, handle_review/2, handle_transition_open_to_under_review/2, handle_transition_under_review_to_resolved/2, handle_transition_under_review_to_escalated/2, handle_transition_escalated_to_resolved/2, handle_transition_resolved_to_open/2]).

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
            case trade_dispute_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(resolved_at, maps:get(resolved_at, M, undefined), maps:remove(resolved_at, M)) end)((fun(M) -> maps:put(opened_at, maps:get(opened_at, M, undefined), maps:remove(opened_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = trade_dispute_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_trade_dispute_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = trade_dispute_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = trade_dispute_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end
.

params_to_record(Id, Params) ->
    #trade_dispute{
        id         = Id,
        status     = maps:get(<<"status">>, Params, <<"Open">>),
        reason     = maps:get(<<"reason">>, Params, undefined),
        description = maps:get(<<"description">>, Params, undefined),
        resolution = maps:get(<<"resolution">>, Params, undefined),
        opened_at  = maps:get(<<"opened_at">>, Params, undefined),
        resolved_at = maps:get(<<"resolved_at">>, Params, undefined),
        transaction_id = maps:get(<<"transaction_id">>, Params, undefined),
        opened_by_id = maps:get(<<"opened_by_id">>, Params, undefined),
        resolved_by_id = maps:get(<<"resolved_by_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#trade_dispute{id = Id, status = Status, reason = Reason, description = Description, resolution = Resolution, opened_at = OpenedAt, resolved_at = ResolvedAt, transaction_id = TransactionId, opened_by_id = OpenedById, resolved_by_id = ResolvedById, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"reason">> => Reason,
        <<"description">> => Description,
        <<"resolution">> => Resolution,
        <<"opened_at">> => OpenedAt,
        <<"resolved_at">> => ResolvedAt,
        <<"transaction_id">> => TransactionId,
        <<"opened_by_id">> => OpenedById,
        <<"resolved_by_id">> => ResolvedById,
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

validate_trade_dispute_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"resolved_at">>, M, undefined) =/= undefined andalso maps:get(<<"resolved_at">>, M, undefined) =/= null)) andalso not ((maps:get(<<"status">>, M, undefined) =:= <<"Resolved">>)) of true -> {true, <<"resolved_at_requires_terminal_status">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_escalate(Req, State) ->
    _ = escalate_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

escalate_behavior(_Record) ->
    %% TODO: implement escalate
    ok.

handle_resolve(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = resolve_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

resolve_behavior(_Record, _Params) ->
    %% TODO: implement resolve(resolution_text)
    ok.

handle_close_resolved(Req, State) ->
    _ = close_resolved_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

close_resolved_behavior(_Record) ->
    %% TODO: implement close_resolved
    ok.

handle_review(Req, State) ->
    _ = review_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

review_behavior(_Record) ->
    %% TODO: implement review
    ok.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_open_to_under_review(Req, State) ->
    %% Transition: Open -> UnderReview
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>, <<"moderator">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Open -> UnderReview">>}), Req), State};
        true  ->
    ok = trade_dispute_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"UnderReview">>),
    ok = trade_dispute_store:update_field(maps:get(<<"id">>, State), status, <<"UnderReview">>),
    review_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"UnderReview">>}), Req), State}
    end.

handle_transition_under_review_to_resolved(Req, State) ->
    %% Transition: UnderReview -> Resolved
    %% @on guard: [{"type":"neq","field":"resolution","value":"null"}]
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>, <<"moderator">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition UnderReview -> Resolved">>}), Req), State};
        true  ->
    ok = trade_dispute_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Resolved">>),
    ok = trade_dispute_store:update_field(maps:get(<<"id">>, State), status, <<"Resolved">>),
    close_resolved_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Resolved">>}), Req), State}
    end.

handle_transition_under_review_to_escalated(Req, State) ->
    %% Transition: UnderReview -> Escalated
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition UnderReview -> Escalated">>}), Req), State};
        true  ->
    ok = trade_dispute_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Escalated">>),
    ok = trade_dispute_store:update_field(maps:get(<<"id">>, State), status, <<"Escalated">>),
    escalate_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Escalated">>}), Req), State}
    end.

handle_transition_escalated_to_resolved(Req, State) ->
    %% Transition: Escalated -> Resolved
    %% @on guard: [{"type":"neq","field":"resolution","value":"null"}]
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Escalated -> Resolved">>}), Req), State};
        true  ->
    ok = trade_dispute_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Resolved">>),
    ok = trade_dispute_store:update_field(maps:get(<<"id">>, State), status, <<"Resolved">>),
    close_resolved_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Resolved">>}), Req), State}
    end.

handle_transition_resolved_to_open(Req, State) ->
    %% Transition: Resolved -> Open
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition Resolved -> Open is not allowed">>}), Req), State}.

