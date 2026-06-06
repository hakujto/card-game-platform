-module(awarded_prize_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/awarded_prizes").

valid_params() ->
    #{
        <<"final_placement">> => 1,
        <<"awarded_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"claimed">> => false,
        <<"prize_id">> => 1,
        <<"player_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(awarded_prize).

awarded_prize_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_awarded_prizes/0,
        fun get_awarded_prize/0
        ]}}.

list_awarded_prizes() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

get_awarded_prize() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "/1", []}, [], []),
    ?assert(lists:member(Code, [200, 404])).

