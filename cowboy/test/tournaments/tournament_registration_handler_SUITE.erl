-module(tournament_registration_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/tournament_registrations").

valid_params() ->
    #{
        <<"status">> => <<"Registered">>,
        <<"points_earned">> => 1,
        <<"registered_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"tournament_id">> => 1,
        <<"player_id">> => 1,
        <<"deck_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(tournament_registration).

tournament_registration_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_tournament_registrations/0,
        fun create_tournament_registration/0,
        fun get_tournament_registration/0
        ]}}.

list_tournament_registrations() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_tournament_registration() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_tournament_registration() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

