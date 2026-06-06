-module(deck_card_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_patch/2, handle_delete/2, delete_resource/2, handle_increment/2, handle_decrement/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PATCH">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    Method = cowboy_req:method(Req),
    Handler = case Method of
        <<"PATCH">> -> handle_patch;
        _           -> handle_post
    end,
    {[{<<"application/json">>, Handler}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case deck_card_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = deck_card_store:all(),
            Body = jsone:encode(All),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_deck_card_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_deck_card_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = deck_card_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = deck_card_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = deck_card_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = deck_card_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    ok = deck_card_store:delete(maps:get(<<"id">>, State)),
    {true, Req, State}.

params_to_record(Id, Params) ->
    #deck_card{
        id         = Id,
        quantity   = maps:get(<<"quantity">>, Params, undefined),
        is_commander = maps:get(<<"is_commander">>, Params, undefined),
        deck_id    = maps:get(<<"deck_id">>, Params, undefined),
        card_id    = maps:get(<<"card_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #deck_card{
        id         = Record#deck_card.id,
        quantity   = maps:get(<<"quantity">>, Params, Record#deck_card.quantity),
        is_commander = maps:get(<<"is_commander">>, Params, Record#deck_card.is_commander),
        deck_id    = maps:get(<<"deck_id">>, Params, Record#deck_card.deck_id),
        card_id    = maps:get(<<"card_id">>, Params, Record#deck_card.card_id),
        created_at = Record#deck_card.created_at,
        updated_at = iso_now()
    }.

record_to_map(#deck_card{id = Id, quantity = Quantity, is_commander = IsCommander, deck_id = DeckId, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"quantity">> => Quantity,
        <<"is_commander">> => IsCommander,
        <<"deck_id">> => DeckId,
        <<"card_id">> => CardId,
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

validate_deck_card_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"quantity">>, M, undefined)) >= 1 andalso to_number(maps:get(<<"quantity">>, M, undefined)) =< 4) of false -> {true, <<"A deck can contain between 1 and 4 copies of a card">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_deck_card_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"is_commander">>, M, undefined) =:= true)) andalso not ((maps:get(<<"quantity">>, M, undefined) =:= 1)) of true -> {true, <<"Commander card must appear exactly once in the deck">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_increment(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = increment_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

increment_behavior(_Record, _Params) ->
    %% TODO: implement increment(amount)
    ok.

handle_decrement(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = decrement_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

decrement_behavior(_Record, _Params) ->
    %% TODO: implement decrement(amount)
    ok.

