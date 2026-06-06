-module(coupon_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#coupon{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(coupon, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(coupon, Id) end,
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
    F = fun() -> mnesia:delete({coupon, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, coupon, 1).

record_to_map(#coupon{id = Id, code = Code, discount_type = DiscountType, discount_value = DiscountValue, min_order_value = MinOrderValue, max_uses = MaxUses, uses_count = UsesCount, valid_from = ValidFrom, valid_until = ValidUntil, is_active = IsActive, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"code">> => Code,
        <<"discount_type">> => DiscountType,
        <<"discount_value">> => DiscountValue,
        <<"min_order_value">> => MinOrderValue,
        <<"max_uses">> => MaxUses,
        <<"uses_count">> => UsesCount,
        <<"valid_from">> => ValidFrom,
        <<"valid_until">> => ValidUntil,
        <<"is_active">> => IsActive,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

