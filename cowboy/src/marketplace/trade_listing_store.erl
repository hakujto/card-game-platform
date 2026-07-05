-module(trade_listing_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2, find_by_seller_id/1, find_by_card_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#trade_listing{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(trade_listing, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(trade_listing, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, R};
        {atomic, []}  -> not_found
    end.

insert(Record) ->
    F = fun() -> mnesia:write(Record) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

update(Record) ->
    F = fun() -> mnesia:write(Record) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

delete(Id) ->
    F = fun() -> mnesia:delete({trade_listing, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, trade_listing, 1).

find_by_seller_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_listing{seller_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_card_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_listing{card_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

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

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(trade_listing, Id),
        mnesia:write(R#trade_listing{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"pending">>, <<"active">>}, {<<"active">>, <<"sold">>}, {<<"active">>, <<"expired">>}, {<<"active">>, <<"cancelled">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

