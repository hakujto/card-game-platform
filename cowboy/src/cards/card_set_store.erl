-module(card_set_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#card_set{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(card_set, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(card_set, Id) end,
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
    F = fun() -> mnesia:delete({card_set, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, card_set, 1).

record_to_map(#card_set{id = Id, name = Name, code = Code, release_date = ReleaseDate, rotation_date = RotationDate, set_type = SetType, total_cards = TotalCards, is_rotated = IsRotated, description = Description, logo_url = LogoUrl, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"code">> => Code,
        <<"release_date">> => ReleaseDate,
        <<"rotation_date">> => RotationDate,
        <<"set_type">> => SetType,
        <<"total_cards">> => TotalCards,
        <<"is_rotated">> => IsRotated,
        <<"description">> => Description,
        <<"logo_url">> => LogoUrl,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

