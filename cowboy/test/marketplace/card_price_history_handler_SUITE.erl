-module(card_price_history_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/card_price_histories").

valid_params() ->
    #{
        <<"price_date">> => <<"2024-01-01">>,
        <<"avg_price">> => 0.0,
        <<"min_price">> => 0.0,
        <<"max_price">> => 0.0,
        <<"volume">> => 1,
        <<"foil">> => true,
        <<"card_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(card_price_history).

card_price_history_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_card_price_histories/0,
        fun get_card_price_history/0
        ]}}.

list_card_price_histories() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

get_card_price_history() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "/1", []}, [], []),
    ?assert(lists:member(Code, [200, 404])).

