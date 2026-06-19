-module(trade_bid_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_outbid_by/2, handle_retract/2]).

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
            case trade_bid_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(placed_at, maps:get(placed_at, M, undefined), maps:remove(placed_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = trade_bid_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_trade_bid_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = trade_bid_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = trade_bid_store:insert(Record),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end
.

params_to_record(Id, Params) ->
    #trade_bid{
        id         = Id,
        amount     = maps:get(<<"amount">>, Params, undefined),
        placed_at  = maps:get(<<"placed_at">>, Params, undefined),
        is_winning = maps:get(<<"is_winning">>, Params, false),
        listing_id = maps:get(<<"listing_id">>, Params, undefined),
        bidder_id  = maps:get(<<"bidder_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#trade_bid{id = Id, amount = Amount, placed_at = PlacedAt, is_winning = IsWinning, listing_id = ListingId, bidder_id = BidderId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"amount">> => Amount,
        <<"placed_at">> => PlacedAt,
        <<"is_winning">> => IsWinning,
        <<"listing_id">> => ListingId,
        <<"bidder_id">> => BidderId,
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

validate_trade_bid_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"amount">>, M, undefined)) > 0) of false -> {true, <<"Bid amount must be greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_outbid_by(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = outbid_by_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

outbid_by_behavior(_Record, _Params) ->
    %% TODO: implement outbid_by(new_amount)
    null.

handle_retract(Req, State) ->
    _ = retract_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

retract_behavior(_Record) ->
    %% TODO: implement retract
    ok.

