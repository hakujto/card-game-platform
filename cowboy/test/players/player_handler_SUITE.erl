-module(player_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/players").

valid_params() ->
    #{
        <<"display_name">> => <<"test">>,
        <<"rank">> => <<"Bronze">>,
        <<"rating">> => 1,
        <<"peak_rating">> => 1,
        <<"is_verified">> => true,
        <<"created_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"user_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(player).

player_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_players/0,
        fun create_player/0,
        fun get_player/0,
        fun update_player/0,
        fun search_players/0
        ]}}.

list_players() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_player() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_player() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_player() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    PatchBody = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(patch,
        {Url, [], "application/json", PatchBody}, [], []),
    ?assertEqual(200, Code).

search_players() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

