-module(article_handler_SUITE).
-include_lib("eunit/include/eunit.hrl").

-define(BASE_URL, "http://localhost:8080/api/articles").

valid_params() ->
    #{
        <<"title">> => <<"test">>,
        <<"slug">> => <<"test">>,
        <<"body">> => <<"test">>,
        <<"status">> => <<"Draft">>,
        <<"article_type">> => <<"Guide">>,
        <<"language">> => <<"EN">>,
        <<"view_count">> => 1,
        <<"likes_count">> => 1,
        <<"is_featured">> => true,
        <<"created_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"updated_at">> => <<"2024-01-01T00:00:00Z">>,
        <<"author_id">> => 1
    }.

setup_suite() ->
    application:ensure_all_started(cards_project),
    inets:start().

teardown_suite(_) ->
    ok.

per_test() ->
    mnesia:clear_table(article).

article_handler_SUITE_test_() ->
    {setup, fun setup_suite/0, fun teardown_suite/1,
        {foreach, fun per_test/0, fun(_) -> ok end, [
        fun list_articles/0,
        fun create_article/0,
        fun get_article/0,
        fun update_article/0,
        fun search_articles/0
        ]}}.

list_articles() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL, []}, [], []),
    ?assertEqual(200, Code).

create_article() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, Code, _}, _, _}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    ?assertEqual(201, Code).

get_article() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {Url, []}, [], []),
    ?assertEqual(200, Code).

update_article() ->
    Body = jsone:encode(valid_params()),
    {ok, {{_, 201, _}, _, RespBody}} = httpc:request(post,
        {?BASE_URL, [], "application/json", Body}, [], []),
    #{<<"id">> := Id} = jsone:decode(list_to_binary(RespBody)),
    Url = ?BASE_URL ++ "/" ++ integer_to_list(Id),
    {ok, {{_, Code, _}, _, _}} = httpc:request(put,
        {Url, [], "application/json", Body}, [], []),
    ?assertEqual(200, Code).

search_articles() ->
    {ok, {{_, Code, _}, _, _}} = httpc:request(get, {?BASE_URL ++ "?q=test", []}, [], []),
    ?assertEqual(200, Code).

