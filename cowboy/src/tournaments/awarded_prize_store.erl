-module(awarded_prize_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_prize_id/1, find_by_player_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#awarded_prize{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(awarded_prize, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(awarded_prize, Id) end,
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
    F = fun() -> mnesia:delete({awarded_prize, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, awarded_prize, 1).

find_by_prize_id(FKId) ->
    F = fun() -> mnesia:match_object(#awarded_prize{prize_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_player_id(FKId) ->
    F = fun() -> mnesia:match_object(#awarded_prize{player_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

record_to_map(#awarded_prize{id = Id, final_placement = FinalPlacement, awarded_at = AwardedAt, claimed = Claimed, claimed_at = ClaimedAt, prize_id = PrizeId, player_id = PlayerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"final_placement">> => FinalPlacement,
        <<"awarded_at">> => AwardedAt,
        <<"claimed">> => Claimed,
        <<"claimed_at">> => ClaimedAt,
        <<"prize_id">> => PrizeId,
        <<"player_id">> => PlayerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

