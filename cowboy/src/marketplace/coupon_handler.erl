-module(coupon_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_is_valid/2, handle_is_applicable_to_order/2, handle_redeem/2, handle_deactivate/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"PUT">>, <<"PATCH">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    Method = cowboy_req:method(Req),
    Handler = case Method of
        <<"PUT">>   -> handle_put;
        <<"PATCH">> -> handle_patch;
        _           -> handle_post
    end,
    {[{<<"application/json">>, Handler}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case coupon_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

allow_missing_post(Req, State) -> {false, Req, State}.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            Qs = cowboy_req:parse_qs(Req),
            Q  = proplists:get_value(<<"q">>, Qs, <<"">>),
            All = coupon_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(code, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(Filtered),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_coupon_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_coupon_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = coupon_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = coupon_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = coupon_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = coupon_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #coupon{
        id         = Id,
        code       = maps:get(<<"code">>, Params, undefined),
        discount_type = maps:get(<<"discount_type">>, Params, <<"Percent">>),
        discount_value = maps:get(<<"discount_value">>, Params, undefined),
        min_order_value = maps:get(<<"min_order_value">>, Params, 0),
        max_uses   = maps:get(<<"max_uses">>, Params, undefined),
        uses_count = maps:get(<<"uses_count">>, Params, 0),
        valid_from = maps:get(<<"valid_from">>, Params, undefined),
        valid_until = maps:get(<<"valid_until">>, Params, undefined),
        is_active  = maps:get(<<"is_active">>, Params, true),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #coupon{
        id         = Record#coupon.id,
        code       = maps:get(<<"code">>, Params, Record#coupon.code),
        discount_type = maps:get(<<"discount_type">>, Params, Record#coupon.discount_type),
        discount_value = maps:get(<<"discount_value">>, Params, Record#coupon.discount_value),
        min_order_value = maps:get(<<"min_order_value">>, Params, Record#coupon.min_order_value),
        max_uses   = maps:get(<<"max_uses">>, Params, Record#coupon.max_uses),
        uses_count = maps:get(<<"uses_count">>, Params, Record#coupon.uses_count),
        valid_from = maps:get(<<"valid_from">>, Params, Record#coupon.valid_from),
        valid_until = maps:get(<<"valid_until">>, Params, Record#coupon.valid_until),
        is_active  = maps:get(<<"is_active">>, Params, Record#coupon.is_active),
        created_at = Record#coupon.created_at,
        updated_at = iso_now()
    }.

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

validate_coupon_rules(M) ->
    Checks = [
        fun() -> case (maps:get(<<"valid_until">>, M, undefined) > maps:get(<<"valid_from">>, M, undefined)) of false -> {true, <<"Coupon expiry must be after its start date">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"discount_value">>, M, undefined)) > 0) of false -> {true, <<"Discount value must be greater than zero">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_coupon_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"discount_type">>, M, undefined) =:= <<"Percent">>)) andalso not ((to_number(maps:get(<<"discount_value">>, M, undefined)) >= 1 andalso to_number(maps:get(<<"discount_value">>, M, undefined)) =< 100)) of true -> {true, <<"Percent discount must be between 1 and 100">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"max_uses">>, M, undefined) =/= undefined andalso maps:get(<<"max_uses">>, M, undefined) =/= null)) andalso not ((to_number(maps:get(<<"uses_count">>, M, undefined)) =< to_number(maps:get(<<"max_uses">>, M, undefined)))) of true -> {true, <<"Coupon uses count cannot exceed max_uses">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_is_valid(Req, State) ->
    Result = is_valid_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_valid_behavior(_Record) ->
    %% TODO: implement is_valid
    null.

handle_is_applicable_to_order(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = is_applicable_to_order_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

is_applicable_to_order_behavior(_Record, _Params) ->
    %% TODO: implement is_applicable_to_order(order_total)
    null.

handle_redeem(Req, State) ->
    case check_guard_redeem(State) of
        false -> reply_422(Req, [<<"Guard condition not met for redeem">>], State);
        true  ->
    _ = redeem_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}
    end.

check_guard_redeem(_Record) ->
    %% TODO: evaluate guard for redeem
    true.

redeem_behavior(_Record) ->
    %% TODO: implement redeem
    ok.

handle_deactivate(Req, State) ->
    _ = deactivate_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

deactivate_behavior(_Record) ->
    %% TODO: implement deactivate
    ok.

