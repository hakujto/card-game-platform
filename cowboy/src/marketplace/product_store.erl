-module(product_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#product{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(product, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(product, Id) end,
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
    F = fun() -> mnesia:delete({product, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, product, 1).

record_to_map(#product{id = Id, name = Name, product_type = ProductType, price = Price, stock = Stock, active = Active, discount_percent = DiscountPercent, description = Description, image_url = ImageUrl, featured = Featured, card_id = CardId, card_set_id = CardSetId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"product_type">> => ProductType,
        <<"price">> => Price,
        <<"stock">> => Stock,
        <<"active">> => Active,
        <<"discount_percent">> => DiscountPercent,
        <<"description">> => Description,
        <<"image_url">> => ImageUrl,
        <<"featured">> => Featured,
        <<"card_id">> => CardId,
        <<"card_set_id">> => CardSetId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

