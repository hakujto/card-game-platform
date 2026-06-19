-module(achievement_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/achievements").

valid_params() ->
    #{
        <<"name">> => <<"test">>,
        <<"description">> => <<"test">>,
        <<"points">> => 1,
        <<"rarity">> => <<"Common">>,
        <<"is_hidden">> => true
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(achievement).

achievement_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_achievements/0,
        fun create_achievement/0,
        fun get_achievement/0,
        fun update_achievement/0,
        fun search_achievements/0
        ]}}.

list_achievements() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_achievement() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_achievement() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_achievement() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    PatchBody = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(put,
        {Url, [], "application/json", PatchBody}, [], []),
    ?assertEqual(200, Code).

search_achievements() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

