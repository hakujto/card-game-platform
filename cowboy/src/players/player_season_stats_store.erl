-module(player_season_stats_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#player_season_stats{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(player_season_stats, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(player_season_stats, Id) end,
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
    F = fun() -> mnesia:delete({player_season_stats, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, player_season_stats, 1).

record_to_map(#player_season_stats{id = Id, wins = Wins, losses = Losses, draws = Draws, tournament_wins = TournamentWins, highest_rank = HighestRank, season_points = SeasonPoints, player_id = PlayerId, season_id = SeasonId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"wins">> => Wins,
        <<"losses">> => Losses,
        <<"draws">> => Draws,
        <<"tournament_wins">> => TournamentWins,
        <<"highest_rank">> => HighestRank,
        <<"season_points">> => SeasonPoints,
        <<"player_id">> => PlayerId,
        <<"season_id">> => SeasonId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

