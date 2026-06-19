-module(trade_transaction_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_listing_id/1, find_by_buyer_id/1, find_by_seller_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#trade_transaction{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(trade_transaction, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(trade_transaction, Id) end,
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
    F = fun() -> mnesia:delete({trade_transaction, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, trade_transaction, 1).

find_by_listing_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_transaction{listing_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_buyer_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_transaction{buyer_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_seller_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_transaction{seller_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

record_to_map(#trade_transaction{id = Id, final_price = FinalPrice, platform_fee = PlatformFee, status = Status, completed_at = CompletedAt, listing_id = ListingId, buyer_id = BuyerId, seller_id = SellerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"final_price">> => FinalPrice,
        <<"platform_fee">> => PlatformFee,
        <<"status">> => Status,
        <<"completed_at">> => CompletedAt,
        <<"listing_id">> => ListingId,
        <<"buyer_id">> => BuyerId,
        <<"seller_id">> => SellerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

