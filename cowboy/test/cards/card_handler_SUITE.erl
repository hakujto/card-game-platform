-module(card_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/cards").

valid_params() ->
    #{
        <<"public_id">> => <<"00000000-0000-0000-0000-000000000001">>,
        <<"name">> => <<"test">>,
        <<"card_type">> => <<"Creature">>,
        <<"rarity">> => <<"Common">>,
        <<"mana_cost">> => 1,
        <<"mana_colors">> => <<"White">>,
        <<"attack">> => 1,
        <<"defense">> => 1,
        <<"description">> => <<"test">>,
        <<"legal_formats">> => <<"Standard">>,
        <<"is_banned">> => false,
        <<"is_restricted">> => false,
        <<"power_level">> => 1,
        <<"total_copies_in_circulation">> => 1,
        <<"set_id">> => 1
    }.

patch_params() ->
    #{<<"flavor_text">> => <<"test">>}.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(card).

card_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_cards/0,
        fun create_card/0,
        fun get_card/0,
        fun update_card/0,
        fun search_cards/0
        ]}}.

list_cards() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_card() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_card() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_card() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    PatchBody = jsone:encode(patch_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(put,
        {Url, [], "application/json", PatchBody}, [], []),
    ?assertEqual(200, Code).

search_cards() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

