-module(tournament_registration_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_withdraw/2, handle_disqualify/2, handle_promote_from_waitlist/2]).

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
            case tournament_registration_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(registered_at, maps:get(registered_at, M, undefined), maps:remove(registered_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = tournament_registration_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            UserId = cowboy_req:header(<<"x-user-id">>, Req, undefined),
            OwnerId = maps:get(<<"player_id">>, State, undefined),
            case UserId =:= (if is_integer(OwnerId) -> integer_to_binary(OwnerId); true -> OwnerId end) of
                false ->
                    Req2 = cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>}, <<"{\"error\":\"You do not own this resource.\"}">>, Req),
                    {stop, Req2, State};
                true ->
                    Body = jsone:encode(apply_projection(State)),
                    {Body, Req, State}
            end
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_tournament_registration_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_tournament_registration_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = tournament_registration_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = tournament_registration_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

params_to_record(Id, Params) ->
    #tournament_registration{
        id         = Id,
        status     = maps:get(<<"status">>, Params, <<"Registered">>),
        seed       = maps:get(<<"seed">>, Params, undefined),
        final_standing = maps:get(<<"final_standing">>, Params, undefined),
        points_earned = maps:get(<<"points_earned">>, Params, 0),
        registered_at = maps:get(<<"registered_at">>, Params, undefined),
        tournament_id = maps:get(<<"tournament_id">>, Params, undefined),
        player_id  = maps:get(<<"player_id">>, Params, undefined),
        deck_id    = maps:get(<<"deck_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#tournament_registration{id = Id, status = Status, seed = Seed, final_standing = FinalStanding, points_earned = PointsEarned, registered_at = RegisteredAt, tournament_id = TournamentId, player_id = PlayerId, deck_id = DeckId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"seed">> => Seed,
        <<"final_standing">> => FinalStanding,
        <<"points_earned">> => PointsEarned,
        <<"registered_at">> => RegisteredAt,
        <<"tournament_id">> => TournamentId,
        <<"player_id">> => PlayerId,
        <<"deck_id">> => DeckId,
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

validate_tournament_registration_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"points_earned">>, M, undefined)) >= 0) of false -> {true, <<"Points earned must not be negative">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_tournament_registration_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"final_standing">>, M, undefined) =/= undefined andalso maps:get(<<"final_standing">>, M, undefined) =/= null)) andalso not ((to_number(maps:get(<<"final_standing">>, M, undefined)) > 0)) of true -> {true, <<"Final standing must be greater than zero">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"seed">>, M, undefined) =/= undefined andalso maps:get(<<"seed">>, M, undefined) =/= null)) andalso not ((to_number(maps:get(<<"seed">>, M, undefined)) > 0)) of true -> {true, <<"Seed must be greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_withdraw(Req, State) ->
    _ = withdraw_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

withdraw_behavior(_Record) ->
    %% TODO: implement withdraw
    ok.

handle_disqualify(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = disqualify_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

disqualify_behavior(_Record, _Params) ->
    %% TODO: implement disqualify(reason)
    ok.

handle_promote_from_waitlist(Req, State) ->
    _ = promote_from_waitlist_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

promote_from_waitlist_behavior(_Record) ->
    %% TODO: implement promote_from_waitlist
    ok.

