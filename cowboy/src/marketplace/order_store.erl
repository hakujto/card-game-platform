-module(order_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0, update_field/3, assert_transition/2]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#order{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(order, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(order, Id) end,
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
    F = fun() -> mnesia:delete({order, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, order, 1).

record_to_map(#order{id = Id, status = Status, total = Total, discount_applied = DiscountApplied, currency = Currency, payment_method = PaymentMethod, payment_reference = PaymentReference, shipping_address = ShippingAddress, tracking_number = TrackingNumber, paid_at = PaidAt, shipped_at = ShippedAt, player_id = PlayerId, coupon_id = CouponId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"status">> => Status,
        <<"total">> => Total,
        <<"discount_applied">> => DiscountApplied,
        <<"currency">> => Currency,
        <<"payment_method">> => PaymentMethod,
        <<"payment_reference">> => PaymentReference,
        <<"shipping_address">> => ShippingAddress,
        <<"tracking_number">> => TrackingNumber,
        <<"paid_at">> => PaidAt,
        <<"shipped_at">> => ShippedAt,
        <<"player_id">> => PlayerId,
        <<"coupon_id">> => CouponId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

update_field(Id, status, Value) ->
    F = fun() ->
        [R] = mnesia:read(order, Id),
        mnesia:write(R#order{status = Value})
    end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

allowed_transitions() ->
    [{<<"pending">>, <<"paid">>}, {<<"paid">>, <<"processing">>}, {<<"processing">>, <<"shipped">>}, {<<"shipped">>, <<"completed">>}, {<<"pending">>, <<"cancelled">>}, {<<"paid">>, <<"cancelled">>}, {<<"completed">>, <<"refunded">>}].

assert_transition(From, To) ->
    case lists:member({From, To}, allowed_transitions()) of
        true  -> ok;
        false -> error({transition_not_allowed, From, To})
    end.

