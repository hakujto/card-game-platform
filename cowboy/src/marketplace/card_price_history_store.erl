-module(card_price_history_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_card_id/1, delete_by_card_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#card_price_history{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(card_price_history, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(card_price_history, Id) end,
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
    F = fun() -> mnesia:delete({card_price_history, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, card_price_history, 1).

find_by_card_id(FKId) ->
    F = fun() -> mnesia:match_object(#card_price_history{card_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_card_id(FKId) ->
    Records = find_by_card_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#card_price_history{id = Id, price_date = PriceDate, avg_price = AvgPrice, min_price = MinPrice, max_price = MaxPrice, volume = Volume, foil = Foil, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"price_date">> => PriceDate,
        <<"avg_price">> => AvgPrice,
        <<"min_price">> => MinPrice,
        <<"max_price">> => MaxPrice,
        <<"volume">> => Volume,
        <<"foil">> => Foil,
        <<"card_id">> => CardId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

