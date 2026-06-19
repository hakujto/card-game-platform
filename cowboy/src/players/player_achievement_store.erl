-module(player_achievement_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_player_id/1, find_by_achievement_id/1, delete_by_player_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#player_achievement{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(player_achievement, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(player_achievement, Id) end,
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
    F = fun() -> mnesia:delete({player_achievement, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, player_achievement, 1).

find_by_player_id(FKId) ->
    F = fun() -> mnesia:match_object(#player_achievement{player_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_achievement_id(FKId) ->
    F = fun() -> mnesia:match_object(#player_achievement{achievement_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_player_id(FKId) ->
    Records = find_by_player_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#player_achievement{id = Id, earned_at = EarnedAt, progress = Progress, is_completed = IsCompleted, player_id = PlayerId, achievement_id = AchievementId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"earned_at">> => EarnedAt,
        <<"progress">> => Progress,
        <<"is_completed">> => IsCompleted,
        <<"player_id">> => PlayerId,
        <<"achievement_id">> => AchievementId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

