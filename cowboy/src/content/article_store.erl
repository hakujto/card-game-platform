-module(article_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2, find_by_author_id/1, find_by_featured_deck_id/1]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#article{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(article, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(article, Id) end,
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
    F = fun() -> mnesia:delete({article, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, article, 1).

find_by_author_id(FKId) ->
    F = fun() -> mnesia:match_object(#article{author_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find_by_featured_deck_id(FKId) ->
    F = fun() -> mnesia:match_object(#article{featured_deck_id = FKId, _ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

record_to_map(#article{id = Id, title = Title, slug = Slug, body = Body, excerpt = Excerpt, cover_image_url = CoverImageUrl, status = Status, article_type = ArticleType, language = Language, view_count = ViewCount, likes_count = LikesCount, total_views_alltime = TotalViewsAlltime, is_featured = IsFeatured, published_at = PublishedAt, author_id = AuthorId, featured_deck_id = FeaturedDeckId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"title">> => Title,
        <<"slug">> => Slug,
        <<"body">> => Body,
        <<"excerpt">> => Excerpt,
        <<"cover_image_url">> => CoverImageUrl,
        <<"status">> => Status,
        <<"article_type">> => ArticleType,
        <<"language">> => Language,
        <<"view_count">> => ViewCount,
        <<"likes_count">> => LikesCount,
        <<"total_views_alltime">> => TotalViewsAlltime,
        <<"is_featured">> => IsFeatured,
        <<"published_at">> => PublishedAt,
        <<"author_id">> => AuthorId,
        <<"featured_deck_id">> => FeaturedDeckId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(article, Id),
        mnesia:write(R#article{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"draft">>, <<"published">>}, {<<"published">>, <<"archived">>}, {<<"archived">>, <<"draft">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

