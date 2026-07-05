%% Domain events for tournaments

%% Event emitted by Tournament
-record(tournamentcompleted, {
    tournament_id :: integer(),
    season_id :: integer(),
    completed_at :: binary()
}).

%% Event emitted by Tournament
-record(playerregistered, {
    tournament_id :: integer(),
    player_id :: integer(),
    registered_at :: binary()
}).
