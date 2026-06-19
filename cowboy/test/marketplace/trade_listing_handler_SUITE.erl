-module(trade_listing_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/trade_listings").

valid_params() ->
    #{
        <<"status">> => <<"Active">>,
        <<"listing_type">> => <<"FixedPrice">>,
        <<"asking_price">> => 1,
        <<"foil">> => true,
        <<"condition">> => <<"Mint">>,
        <<"quantity">> => 1,
        <<"created_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"seller_id">> => 1,
        <<"card_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(trade_listing).

trade_listing_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_trade_listings/0,
        fun create_trade_listing/0,
        fun get_trade_listing/0,
        fun update_trade_listing/0,
        fun search_trade_listings/0
        ]}}.

list_trade_listings() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_trade_listing() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_trade_listing() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_trade_listing() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    PatchBody = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(patch,
        {Url, [], "application/json", PatchBody}, [], []),
    ?assertEqual(200, Code).

search_trade_listings() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

