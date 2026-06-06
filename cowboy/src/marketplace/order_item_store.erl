-module(order_item_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#order_item{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(order_item, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(order_item, Id) end,
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
    F = fun() -> mnesia:delete({order_item, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, order_item, 1).

record_to_map(#order_item{id = Id, quantity = Quantity, price_at_purchase = PriceAtPurchase, foil = Foil, order_id = OrderId, product_id = ProductId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"quantity">> => Quantity,
        <<"price_at_purchase">> => PriceAtPurchase,
        <<"foil">> => Foil,
        <<"order_id">> => OrderId,
        <<"product_id">> => ProductId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

