-module(card_ability_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_card_id/1, delete_by_card_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#card_ability{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(card_ability, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(card_ability, Id) end,
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
    F = fun() -> mnesia:delete({card_ability, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, card_ability, 1).

find_by_card_id(FKId) ->
    F = fun() -> mnesia:match_object(#card_ability{card_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_card_id(FKId) ->
    Records = find_by_card_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#card_ability{id = Id, ability_type = AbilityType, keyword = Keyword, ability_text = AbilityText, timing = Timing, card_id = CardId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"ability_type">> => AbilityType,
        <<"keyword">> => Keyword,
        <<"ability_text">> => AbilityText,
        <<"timing">> => Timing,
        <<"card_id">> => CardId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

