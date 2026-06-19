-module(deck_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_delete/2, delete_resource/2, handle_validate_size/2, handle_add_card/2, handle_remove_card/2, handle_win_rate/2, handle_clone/2, handle_publish/2, handle_unpublish/2, handle_certify_tournament_legal/2]).

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
            case deck_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(updated_at, maps:get(updated_at, M, undefined), maps:remove(updated_at, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = deck_store:all(),
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
    case validate_deck_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_deck_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = deck_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = deck_store:insert(Record),
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
    {ok, ExistingRecord} = deck_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = deck_store:update(Updated),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    ok = deck_store:delete(maps:get(<<"id">>, State)),
    {true, Req, State}.

params_to_record(Id, Params) ->
    #deck{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        description = maps:get(<<"description">>, Params, undefined),
        format     = maps:get(<<"format">>, Params, <<"Standard">>),
        is_public  = maps:get(<<"is_public">>, Params, false),
        is_tournament_legal = maps:get(<<"is_tournament_legal">>, Params, false),
        archetype  = maps:get(<<"archetype">>, Params, undefined),
        wins       = maps:get(<<"wins">>, Params, 0),
        losses     = maps:get(<<"losses">>, Params, 0),
        draws      = maps:get(<<"draws">>, Params, 0),
        player_id  = maps:get(<<"player_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #deck{
        id         = Record#deck.id,
        name       = maps:get(<<"name">>, Params, Record#deck.name),
        description = maps:get(<<"description">>, Params, Record#deck.description),
        format     = maps:get(<<"format">>, Params, Record#deck.format),
        is_public  = maps:get(<<"is_public">>, Params, Record#deck.is_public),
        is_tournament_legal = maps:get(<<"is_tournament_legal">>, Params, Record#deck.is_tournament_legal),
        archetype  = maps:get(<<"archetype">>, Params, Record#deck.archetype),
        wins       = maps:get(<<"wins">>, Params, Record#deck.wins),
        losses     = maps:get(<<"losses">>, Params, Record#deck.losses),
        draws      = maps:get(<<"draws">>, Params, Record#deck.draws),
        player_id  = maps:get(<<"player_id">>, Params, Record#deck.player_id),
        created_at = Record#deck.created_at,
        updated_at = iso_now()
    }.

record_to_map(#deck{id = Id, name = Name, description = Description, format = Format, is_public = IsPublic, is_tournament_legal = IsTournamentLegal, archetype = Archetype, wins = Wins, losses = Losses, draws = Draws, player_id = PlayerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"description">> => Description,
        <<"format">> => Format,
        <<"is_public">> => IsPublic,
        <<"is_tournament_legal">> => IsTournamentLegal,
        <<"archetype">> => Archetype,
        <<"wins">> => Wins,
        <<"losses">> => Losses,
        <<"draws">> => Draws,
        <<"player_id">> => PlayerId,
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

validate_deck_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"wins">>, M, undefined)) >= 0) of false -> {true, <<"Deck wins count must not be negative">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"losses">>, M, undefined)) >= 0) of false -> {true, <<"Deck losses count must not be negative">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"draws">>, M, undefined)) >= 0) of false -> {true, <<"Deck draws count must not be negative">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_deck_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"is_tournament_legal">>, M, undefined) =:= true)) andalso not ((maps:get(<<"is_public">>, M, undefined) =:= true)) of true -> {true, <<"Tournament-legal deck must be made public">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_validate_size(Req, State) ->
    Result = validate_size_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

validate_size_behavior(_Record) ->
    %% TODO: implement validate_size
    null.

handle_add_card(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = add_card_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

add_card_behavior(_Record, _Params) ->
    %% TODO: implement add_card(card_id, quantity)
    ok.

handle_remove_card(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = remove_card_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

remove_card_behavior(_Record, _Params) ->
    %% TODO: implement remove_card(card_id)
    ok.

handle_win_rate(Req, State) ->
    Result = win_rate_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

win_rate_behavior(_Record) ->
    %% TODO: implement win_rate
    null.

handle_clone(Req, State) ->
    Result = clone_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

clone_behavior(_Record) ->
    %% TODO: implement clone
    null.

handle_publish(Req, State) ->
    _ = publish_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

publish_behavior(_Record) ->
    %% TODO: implement publish
    ok.

handle_unpublish(Req, State) ->
    _ = unpublish_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

unpublish_behavior(_Record) ->
    %% TODO: implement unpublish
    ok.

handle_certify_tournament_legal(Req, State) ->
    Result = certify_tournament_legal_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

certify_tournament_legal_behavior(_Record) ->
    %% TODO: implement certify_tournament_legal
    null.

