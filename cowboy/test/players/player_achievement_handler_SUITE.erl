-module(player_achievement_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/player_achievements").

valid_params() ->
    #{
        <<"earned_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"progress">> => 1,
        <<"is_completed">> => false,
        <<"player_id">> => 1,
        <<"achievement_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(player_achievement).

player_achievement_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_player_achievements/0,
        fun get_player_achievement/0
        ]}}.

list_player_achievements() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

get_player_achievement() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "/1", []}, [], []),
    ?assert(lists:member(Code, [200, 404])).

