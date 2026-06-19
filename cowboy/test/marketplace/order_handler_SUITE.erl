-module(order_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/orders").

valid_params() ->
    #{
        <<"status">> => <<"Pending">>,
        <<"total">> => 0.0,
        <<"discount_applied">> => 0.0,
        <<"currency">> => <<"test">>,
        <<"created_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"player_id">> => <<"owner-1">>
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(order).

order_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_orders/0,
        fun create_order/0,
        fun get_order/0
        ]}}.

list_orders() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_order() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_order() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, [{"X-User-Id", "owner-1"}]}, [], []),
    ?assertEqual(200, Code).

