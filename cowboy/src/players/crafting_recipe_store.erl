-module(crafting_recipe_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_result_card_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#crafting_recipe{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(crafting_recipe, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(crafting_recipe, Id) end,
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
    F = fun() -> mnesia:delete({crafting_recipe, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, crafting_recipe, 1).

find_by_result_card_id(FKId) ->
    F = fun() -> mnesia:match_object(#crafting_recipe{result_card_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

record_to_map(#crafting_recipe{id = Id, dust_cost = DustCost, is_available = IsAvailable, result_card_id = ResultCardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"dust_cost">> => DustCost,
        <<"is_available">> => IsAvailable,
        <<"result_card_id">> => ResultCardId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

