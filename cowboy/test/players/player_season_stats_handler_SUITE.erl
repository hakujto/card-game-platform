-module(player_season_stats_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/player_season_statses").

valid_params() ->
    #{
        <<"wins">> => 1,
        <<"losses">> => 1,
        <<"draws">> => 1,
        <<"tournament_wins">> => 1,
        <<"season_points">> => 1,
        <<"player_id">> => 1,
        <<"season_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(player_season_stats).

player_season_stats_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_player_season_statses/0,
        fun get_player_season_stats/0
        ]}}.

list_player_season_statses() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

get_player_season_stats() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "/1", []}, [], []),
    ?assert(lists:member(Code, [200, 404])).

