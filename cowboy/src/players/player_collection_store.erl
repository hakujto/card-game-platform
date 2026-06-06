-module(player_collection_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#player_collection{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(player_collection, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(player_collection, Id) end,
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
    F = fun() -> mnesia:delete({player_collection, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, player_collection, 1).

record_to_map(#player_collection{id = Id, quantity = Quantity, foil = Foil, condition = Condition, acquired_at = AcquiredAt, acquired_via = AcquiredVia, player_id = PlayerId, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"quantity">> => Quantity,
        <<"foil">> => Foil,
        <<"condition">> => Condition,
        <<"acquired_at">> => AcquiredAt,
        <<"acquired_via">> => AcquiredVia,
        <<"player_id">> => PlayerId,
        <<"card_id">> => CardId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

