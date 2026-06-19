-module(deck_sideboard_card_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_deck_id/1, find_by_card_id/1, delete_by_deck_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#deck_sideboard_card{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(deck_sideboard_card, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(deck_sideboard_card, Id) end,
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
    F = fun() -> mnesia:delete({deck_sideboard_card, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, deck_sideboard_card, 1).

find_by_deck_id(FKId) ->
    F = fun() -> mnesia:match_object(#deck_sideboard_card{deck_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_card_id(FKId) ->
    F = fun() -> mnesia:match_object(#deck_sideboard_card{card_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_deck_id(FKId) ->
    Records = find_by_deck_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#deck_sideboard_card{id = Id, quantity = Quantity, deck_id = DeckId, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"quantity">> => Quantity,
        <<"deck_id">> => DeckId,
        <<"card_id">> => CardId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

