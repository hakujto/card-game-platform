-module(article_comment_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, find_by_article_id/1, find_by_author_id/1, find_by_parent_comment_id/1, delete_by_article_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#article_comment{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(article_comment, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(article_comment, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, R};
        {atomic, []}  -> not_found
    end.

insert(Record) ->
    F = fun() -> mnesia:write(Record) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

update(Record) ->
    F = fun() -> mnesia:write(Record) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

delete(Id) ->
    F = fun() -> mnesia:delete({article_comment, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, article_comment, 1).

find_by_article_id(FKId) ->
    F = fun() -> mnesia:match_object(#article_comment{article_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_author_id(FKId) ->
    F = fun() -> mnesia:match_object(#article_comment{author_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_parent_comment_id(FKId) ->
    F = fun() -> mnesia:match_object(#article_comment{parent_comment_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

delete_by_article_id(FKId) ->
    Records = find_by_article_id(FKId),
    lists:foreach(fun(R) -> delete(maps:get(<<"id">>, R)) end, Records).

record_to_map(#article_comment{id = Id, body = Body, is_hidden = IsHidden, article_id = ArticleId, author_id = AuthorId, parent_comment_id = ParentCommentId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"body">> => Body,
        <<"is_hidden">> => IsHidden,
        <<"article_id">> => ArticleId,
        <<"author_id">> => AuthorId,
        <<"parent_comment_id">> => ParentCommentId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

