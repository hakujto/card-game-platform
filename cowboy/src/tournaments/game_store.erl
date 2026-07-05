-module(game_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_match_id/1, find_by_winner_id/1, delete_by_match_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#game{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(game, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(game, Id) end,
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
    F = fun() -> mnesia:delete({game, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, game, 1).

find_by_match_id(FKId) ->
    F = fun() -> mnesia:match_object(#game{match_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_winner_id(FKId) ->
    F = fun() -> mnesia:match_object(#game{winner_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_match_id(FKId) ->
    Records = find_by_match_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#game{id = Id, game_number = GameNumber, winner_side = WinnerSide, complexity_score = ComplexityScore, turns_played = TurnsPlayed, duration_seconds = DurationSeconds, ended_by = EndedBy, replay_url = ReplayUrl, match_id = MatchId, winner_id = WinnerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"game_number">> => GameNumber,
        <<"winner_side">> => WinnerSide,
        <<"complexity_score">> => ComplexityScore,
        <<"turns_played">> => TurnsPlayed,
        <<"duration_seconds">> => DurationSeconds,
        <<"ended_by">> => EndedBy,
        <<"replay_url">> => ReplayUrl,
        <<"match_id">> => MatchId,
        <<"winner_id">> => WinnerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

