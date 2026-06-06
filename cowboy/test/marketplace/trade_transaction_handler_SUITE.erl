-module(trade_transaction_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/trade_transactions").

valid_params() ->
    #{
        <<"final_price">> => 0.01,
        <<"platform_fee">> => 0.0,
        <<"status">> => <<"Pending">>,
        <<"listing_id">> => 1,
        <<"buyer_id">> => 1,
        <<"seller_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(trade_transaction).

trade_transaction_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_trade_transactions/0,
        fun get_trade_transaction/0
        ]}}.

list_trade_transactions() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

get_trade_transaction() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "/1", []}, [], []),
    ?assert(lists:member(Code, [200, 404])).

