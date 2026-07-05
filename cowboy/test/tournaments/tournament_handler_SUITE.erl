-module(tournament_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/tournaments").

valid_params() ->
    #{
        <<"public_id">> => <<"00000000-0000-0000-0000-000000000001">>,
        <<"name">> => <<"test">>,
        <<"status">> => <<"Draft">>,
        <<"format">> => <<"Standard">>,
        <<"tournament_type">> => <<"Swiss">>,
        <<"max_players">> => 2,
        <<"entry_fee">> => 0.0,
        <<"prize_pool">> => 0.0,
        <<"start_time">> => <<"2024-01-01T00:00:00Z">>,
        <<"is_online">> => true,
        <<"created_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"season_id">> => 1,
        <<"organizer_id">> => 1
    }.

patch_params() ->
    #{<<"description">> => <<"test">>}.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(tournament).

tournament_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_tournaments/0,
        fun create_tournament/0,
        fun get_tournament/0,
        fun update_tournament/0,
        fun search_tournaments/0
        ]}}.

list_tournaments() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_tournament() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_tournament() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_tournament() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    PatchBody = jsone:encode(patch_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(put,
        {Url, [], "application/json", PatchBody}, [], []),
    ?assertEqual(200, Code).

search_tournaments() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

