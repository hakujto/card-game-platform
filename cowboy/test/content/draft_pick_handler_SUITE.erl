-module(draft_pick_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/draft_picks").

valid_params() ->
    #{
        <<"pick_number">> => 1,
        <<"pack_number">> => 1,
        <<"picked_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"participant_id">> => 1,
        <<"card_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(draft_pick).

draft_pick_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_draft_picks/0,
        fun get_draft_pick/0
        ]}}.

list_draft_picks() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

get_draft_pick() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "/1", []}, [], []),
    ?assert(lists:member(Code, [200, 404])).

