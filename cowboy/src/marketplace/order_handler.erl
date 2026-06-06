-module(order_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_cancel/2, handle_pay/2, handle_process_payment/2, handle_calculate_total/2, handle_apply_discount/2, handle_refund/2, handle_transition_pending_to_paid/2, handle_transition_paid_to_processing/2, handle_transition_processing_to_shipped/2, handle_transition_shipped_to_completed/2, handle_transition_pending_to_cancelled/2, handle_transition_paid_to_cancelled/2, handle_transition_completed_to_refunded/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, handle_post}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case order_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(shipped_at, maps:get(shipped_at, M, undefined), maps:remove(shipped_at, M)) end)((fun(M) -> maps:put(paid_at, maps:get(paid_at, M, undefined), maps:remove(paid_at, M)) end)((fun(M) -> maps:put(created_at, maps:get(created_at, M, undefined), maps:remove(created_at, M)) end)(Map))).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = order_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_order_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_order_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = order_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = order_store:insert(Record),
    check_on_notify_shipped(record_to_map(Record)),
    Resp   = jsone:encode(apply_projection(record_to_map(Record))),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

params_to_record(Id, Params) ->
    #order{
        id         = Id,
        status     = maps:get(<<"status">>, Params, undefined),
        total      = maps:get(<<"total">>, Params, undefined),
        discount_applied = maps:get(<<"discount_applied">>, Params, undefined),
        currency   = maps:get(<<"currency">>, Params, undefined),
        payment_method = maps:get(<<"payment_method">>, Params, undefined),
        payment_reference = maps:get(<<"payment_reference">>, Params, undefined),
        shipping_address = maps:get(<<"shipping_address">>, Params, undefined),
        tracking_number = maps:get(<<"tracking_number">>, Params, undefined),
        paid_at    = maps:get(<<"paid_at">>, Params, undefined),
        shipped_at = maps:get(<<"shipped_at">>, Params, undefined),
        player_id  = maps:get(<<"player_id">>, Params, undefined),
        coupon_id  = maps:get(<<"coupon_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

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

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

reply_422(Req, Errors, State) ->
    Body = jsone:encode(#{<<"errors">> => Errors}),
    Req2 = cowboy_req:reply(422, #{<<"content-type">> => <<"application/json">>}, Body, Req),
    {stop, Req2, State}.

to_number(V) when is_integer(V) -> float(V);
to_number(V) when is_float(V)   -> V;
to_number(V) when is_binary(V)  ->
    try binary_to_float(V) catch _:_ -> try float(binary_to_integer(V)) catch _:_ -> 0.0 end end;
to_number(_)                    -> 0.0.

validate_order_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"total">>, M, undefined)) >= 0) of false -> {true, <<"Order total must not be negative">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"discount_applied">>, M, undefined)) =< to_number(maps:get(<<"total">>, M, undefined))) of false -> {true, <<"Discount applied cannot exceed order total">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_order_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"status">>, M, undefined) =:= <<"Paid">>)) andalso not ((maps:get(<<"paid_at">>, M, undefined) =/= undefined andalso maps:get(<<"paid_at">>, M, undefined) =/= null)) of true -> {true, <<"Paid order must have paid_at set">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"status">>, M, undefined) =:= <<"Shipped">>)) andalso not ((maps:get(<<"tracking_number">>, M, undefined) =/= undefined andalso maps:get(<<"tracking_number">>, M, undefined) =/= null)) of true -> {true, <<"Shipped order must have a tracking number">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"shipped_at">>, M, undefined) =/= undefined andalso maps:get(<<"shipped_at">>, M, undefined) =/= null)) andalso not ((maps:get(<<"status">>, M, undefined) =:= <<"Shipped">>)) of true -> {true, <<"shipped_at_requires_shipped_status">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_cancel(Req, State) ->
    _ = cancel_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

cancel_behavior(_Record) ->
    %% TODO: implement cancel
    ok.

handle_pay(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = pay_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

pay_behavior(_Record, _Params) ->
    %% TODO: implement pay(payment_ref)
    null.

handle_process_payment(Req, State) ->
    Result = process_payment_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

process_payment_behavior(_Record) ->
    %% TODO: implement process_payment
    null.

handle_calculate_total(Req, State) ->
    Result = calculate_total_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

calculate_total_behavior(_Record) ->
    %% TODO: implement calculate_total
    null.

handle_apply_discount(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = apply_discount_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

apply_discount_behavior(_Record, _Params) ->
    %% TODO: implement apply_discount(percent)
    null.

handle_refund(Req, State) ->
    _ = refund_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

refund_behavior(_Record) ->
    %% TODO: implement refund
    ok.

%% ── After-hooks (called by @after) ──────────────────────────────────
notify_shipped_hook(_State) ->
    %% TODO: implement notify_shipped after-hook
    ok.

%% ── State-triggered behaviors (@on) ─────────────────────────────────
check_on_notify_shipped(Record) ->
    case maps:get(<<"status">>, Record, undefined) of
        <<"Shipped">> -> notify_shipped_behavior(Record);
        _ -> Record
    end.

notify_shipped_behavior(_Record) ->
    %% TODO: implement notify_shipped
    ok.

%% ── Lifecycle transitions ────────────────────────────────────────────
handle_transition_pending_to_paid(Req, State) ->
    %% Transition: Pending -> Paid
    %% @on guard: [{"type":"neq","field":"payment_method","value":"null"}]
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Paid">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Paid">>),
    process_payment_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Paid">>}), Req), State}.

handle_transition_paid_to_processing(Req, State) ->
    %% Transition: Paid -> Processing
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Processing">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Processing">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Processing">>}), Req), State}.

handle_transition_processing_to_shipped(Req, State) ->
    %% Transition: Processing -> Shipped
    %% @on guard: [{"type":"neq","field":"tracking_number","value":"null"}]
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Shipped">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Shipped">>),
    notify_shipped_hook(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Shipped">>}), Req), State}.

handle_transition_shipped_to_completed(Req, State) ->
    %% Transition: Shipped -> Completed
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Completed">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Completed">>),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Completed">>}), Req), State}.

handle_transition_pending_to_cancelled(Req, State) ->
    %% Transition: Pending -> Cancelled
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Cancelled">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Cancelled">>),
    cancel_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Cancelled">>}), Req), State}.

handle_transition_paid_to_cancelled(Req, State) ->
    %% Transition: Paid -> Cancelled
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Cancelled">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Cancelled">>),
    cancel_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Cancelled">>}), Req), State}.

handle_transition_completed_to_refunded(Req, State) ->
    %% Transition: Completed -> Refunded
    ok = order_store:assert_transition(maps:get(<<"status">>, State, undefined), <<"Refunded">>),
    ok = order_store:update_field(maps:get(<<"id">>, State), status, <<"Refunded">>),
    refund_behavior(State),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>},
        jsone:encode(#{<<"state">> => <<"Refunded">>}), Req), State}.

