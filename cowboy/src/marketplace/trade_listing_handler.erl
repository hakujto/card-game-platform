-module(trade_listing_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_patch/2, handle_close/2, handle_extend/2, handle_cancel/2, handle_is_expired/2, handle_finalize_auction/2, handle_transition_pending_to_active/2, handle_transition_active_to_sold/2, handle_transition_active_to_expired/2, handle_transition_active_to_cancelled/2, handle_transition_sold_to_active/2, handle_transition_expired_to_active/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PATCH">>], Req, State}.

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
            case trade_listing_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

apply_projection(Map) ->
    (fun(M) -> maps:put(auction_end_time, maps:get(auction_end_time, M, undefined), maps:remove(auction_end_time, M)) end)((fun(M) -> maps:put(expires_at, maps:get(expires_at, M, undefined), maps:remove(expires_at, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map))).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = trade_listing_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(description, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(lists:map(fun apply_projection/1, Filtered)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_trade_listing_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_trade_listing_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_trade_listing_required_when(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = trade_listing_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = trade_listing_store:insert(Record),
    check_on_finalize_auction(record_to_map(Record)),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = trade_listing_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = trade_listing_store:update(Updated),
    check_on_finalize_auction(record_to_map(Updated)),
    Resp = jsone:encode(apply_projection(record_to_map(Updated))),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #trade_listing{
        id         = Id,
        public_id  = maps:get(<<"public_id">>, Params, undefined),
        status     = maps:get(<<"status">>, Params, <<"Active">>),
        listing_type = maps:get(<<"listing_type">>, Params, <<"FixedPrice">>),
        asking_price = maps:get(<<"asking_price">>, Params, undefined),
        auction_start_price = maps:get(<<"auction_start_price">>, Params, undefined),
        auction_current_bid = maps:get(<<"auction_current_bid">>, Params, undefined),
        auction_end_time = maps:get(<<"auction_end_time">>, Params, undefined),
        foil       = maps:get(<<"foil">>, Params, false),
        condition  = maps:get(<<"condition">>, Params, <<"Mint">>),
        quantity   = maps:get(<<"quantity">>, Params, 1),
        description = maps:get(<<"description">>, Params, undefined),
        expires_at = maps:get(<<"expires_at">>, Params, undefined),
        seller_id  = maps:get(<<"seller_id">>, Params, undefined),
        card_id    = maps:get(<<"card_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #trade_listing{
        id         = Record#trade_listing.id,
        public_id  = maps:get(<<"public_id">>, Params, Record#trade_listing.public_id),
        listing_type = maps:get(<<"listing_type">>, Params, Record#trade_listing.listing_type),
        asking_price = maps:get(<<"asking_price">>, Params, Record#trade_listing.asking_price),
        auction_start_price = maps:get(<<"auction_start_price">>, Params, Record#trade_listing.auction_start_price),
        auction_current_bid = maps:get(<<"auction_current_bid">>, Params, Record#trade_listing.auction_current_bid),
        auction_end_time = maps:get(<<"auction_end_time">>, Params, Record#trade_listing.auction_end_time),
        foil       = maps:get(<<"foil">>, Params, Record#trade_listing.foil),
        condition  = maps:get(<<"condition">>, Params, Record#trade_listing.condition),
        quantity   = maps:get(<<"quantity">>, Params, Record#trade_listing.quantity),
        description = maps:get(<<"description">>, Params, Record#trade_listing.description),
        expires_at = maps:get(<<"expires_at">>, Params, Record#trade_listing.expires_at),
        seller_id  = maps:get(<<"seller_id">>, Params, Record#trade_listing.seller_id),
        card_id    = maps:get(<<"card_id">>, Params, Record#trade_listing.card_id),
        created_at = Record#trade_listing.created_at,
        updated_at = iso_now()
    }.

record_to_map(#trade_listing{id = Id, public_id = PublicId, status = Status, listing_type = ListingType, asking_price = AskingPrice, auction_start_price = AuctionStartPrice, auction_current_bid = AuctionCurrentBid, auction_end_time = AuctionEndTime, foil = Foil, condition = Condition, quantity = Quantity, description = Description, expires_at = ExpiresAt, seller_id = SellerId, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"public_id">> => PublicId,
        <<"status">> => Status,
        <<"listing_type">> => ListingType,
        <<"asking_price">> => AskingPrice,
        <<"auction_start_price">> => AuctionStartPrice,
        <<"auction_current_bid">> => AuctionCurrentBid,
        <<"auction_end_time">> => AuctionEndTime,
        <<"foil">> => Foil,
        <<"condition">> => Condition,
        <<"quantity">> => Quantity,
        <<"description">> => Description,
        <<"expires_at">> => ExpiresAt,
        <<"seller_id">> => SellerId,
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

validate_trade_listing_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"quantity">>, M, undefined)) >= 1 andalso to_number(maps:get(<<"quantity">>, M, undefined)) =< 9999) of false -> {true, <<"Listing quantity must be between 1 and 9999">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_trade_listing_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"listing_type">>, M, undefined) =:= <<"FixedPrice">>)) andalso not ((maps:get(<<"asking_price">>, M, undefined) =/= undefined andalso maps:get(<<"asking_price">>, M, undefined) =/= null)) of true -> {true, <<"Fixed price listing must have an asking price">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"listing_type">>, M, undefined) =:= <<"Auction">>)) andalso not (((maps:get(<<"auction_start_price">>, M, undefined) =/= undefined andalso maps:get(<<"auction_start_price">>, M, undefined) =/= null) andalso (maps:get(<<"auction_end_time">>, M, undefined) =/= undefined andalso maps:get(<<"auction_end_time">>, M, undefined) =/= null))) of true -> {true, <<"Auction listing must have a start price and end time">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_trade_listing_required_when(M) ->
    Checks = [
        fun() -> case (maps:get(<<"listing_type">>, M, undefined) =:= <<"FixedPrice">>) andalso maps:get(<<"asking_price">>, M, undefined) =:= undefined of true -> {true, <<"asking_price is required">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_close(Req, State) ->
    _ = close_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

close_behavior(_Record) ->
    %% TODO: implement close
    ok.

handle_extend(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = extend_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

extend_behavior(_Record, _Params) ->
    %% TODO: implement extend(days)
    ok.

handle_cancel(Req, State) ->
    case check_guard_cancel(State) of
        false -> reply_422(Req, [<<"Guard condition not met for cancel">>], State);
        true  ->
    _ = cancel_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

check_guard_cancel(_Record) ->
    %% TODO: evaluate guard for cancel
    true.

cancel_behavior(_Record) ->
    %% TODO: implement cancel
    ok.

handle_is_expired(Req, State) ->
    Result = is_expired_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_expired_behavior(_Record) ->
    %% TODO: implement is_expired
    null.

handle_finalize_auction(Req, State) ->
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"admin">>, <<"seller">>]) of
        false -> cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for finalize_auction">>}), Req), {stop, Req, State};
        true  ->
    _ = finalize_auction_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

finalize_auction_behavior(_Record) ->
    %% TODO: implement finalize_auction
    ok.

%% ── State-triggered behaviors (@on) ─────────────────────────────────
check_on_finalize_auction(Record) ->
    case maps:get(<<"status">>, Record, undefined) of
        <<"Sold">> -> finalize_auction_behavior(Record);
        _ -> Record
    end.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_pending_to_active(Req, State) ->
    %% Transition: Pending -> Active
    %% @on guard: [{"type":"neq","field":"quantity","value":"null"}]
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"seller">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Pending -> Active">>}), Req), State};
        true  ->
    ok = trade_listing_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Active">>),
    ok = trade_listing_store:update_field(maps:get(<<"id">>, State), status, <<"Active">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Active">>}), Req), State}
    end.

handle_transition_active_to_sold(Req, State) ->
    %% Transition: Active -> Sold
    ok = trade_listing_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Sold">>),
    ok = trade_listing_store:update_field(maps:get(<<"id">>, State), status, <<"Sold">>),
    finalize_auction_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Sold">>}), Req), State}.

handle_transition_active_to_expired(Req, State) ->
    %% Transition: Active -> Expired
    ok = trade_listing_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Expired">>),
    ok = trade_listing_store:update_field(maps:get(<<"id">>, State), status, <<"Expired">>),
    close_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Expired">>}), Req), State}.

handle_transition_active_to_cancelled(Req, State) ->
    %% Transition: Active -> Cancelled
    UserRole = cowboy_req:header(<<"x-user-role">>, Req, undefined),
    case lists:member(UserRole, [<<"seller">>, <<"admin">>]) of
        false -> {false, cowboy_req:reply(403, #{<<"content-type">> => <<"application/json">>},
            jsone:encode(#{<<"error">> => <<"Insufficient role for transition Active -> Cancelled">>}), Req), State};
        true  ->
    ok = trade_listing_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Cancelled">>),
    ok = trade_listing_store:update_field(maps:get(<<"id">>, State), status, <<"Cancelled">>),
    cancel_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Cancelled">>}), Req), State}
    end.

handle_transition_sold_to_active(Req, State) ->
    %% Transition: Sold -> Active
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition Sold -> Active is not allowed">>}), Req), State}.

handle_transition_expired_to_active(Req, State) ->
    %% Transition: Expired -> Active
    %% @deny: transition is never allowed
    {true, cowboy_req:reply(409, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"error">> => <<"Transition Expired -> Active is not allowed">>}), Req), State}.

