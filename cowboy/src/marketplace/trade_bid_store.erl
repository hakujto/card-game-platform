-module(trade_bid_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_listing_id/1, find_by_bidder_id/1, delete_by_listing_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#trade_bid{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(trade_bid, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(trade_bid, Id) end,
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
    F = fun() -> mnesia:delete({trade_bid, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, trade_bid, 1).

find_by_listing_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_bid{listing_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_bidder_id(FKId) ->
    F = fun() -> mnesia:match_object(#trade_bid{bidder_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_listing_id(FKId) ->
    Records = find_by_listing_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

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

