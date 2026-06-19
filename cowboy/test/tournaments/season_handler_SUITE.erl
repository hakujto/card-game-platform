-module(season_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/seasons").

valid_params() ->
    #{
        <<"name">> => <<"test">>,
        <<"start_date">> => <<"2024-01-01">>,
        <<"end_date">> => <<"2024-01-02">>,
        <<"format">> => <<"Standard">>,
        <<"is_active">> => true
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(season).

season_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_seasons/0,
        fun create_season/0,
        fun get_season/0,
        fun update_season/0,
        fun search_seasons/0
        ]}}.

list_seasons() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_season() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_season() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_season() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    PatchBody = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(put,
        {Url, [], "application/json", PatchBody}, [], []),
    ?assertEqual(200, Code).

search_seasons() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

