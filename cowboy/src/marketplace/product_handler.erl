-module(product_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_activate/2, handle_deactivate/2, handle_apply_discount/2, handle_restock/2, handle_effective_price/2, handle_is_in_stock/2]).

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
            case product_store:find(binary_to_integer(Id)) of
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
            All = product_store:all(),
            Filtered = [R || R <- All, Q =:= <<"">> orelse binary:match(maps:get(name, R, <<"">>), Q) =/= nomatch],
            Body = jsone:encode(Filtered),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    case validate_product_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = product_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = product_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
    end
.

handle_put(Req0, State) ->
    case is_map(State) andalso maps:is_key(<<"id">>, State) of
        false -> {stop, cowboy_req:reply(404, #{}, <<>>, Req0), State};
        true  ->
    Id = maps:get(<<"id">>, State),
    {ok, ExistingRecord} = product_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    ok = product_store:update(Updated),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #product{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        product_type = maps:get(<<"product_type">>, Params, <<"SingleCard">>),
        price      = maps:get(<<"price">>, Params, undefined),
        stock      = maps:get(<<"stock">>, Params, 0),
        active     = maps:get(<<"active">>, Params, true),
        discount_percent = maps:get(<<"discount_percent">>, Params, 0),
        description = maps:get(<<"description">>, Params, undefined),
        image_url  = maps:get(<<"image_url">>, Params, undefined),
        featured   = maps:get(<<"featured">>, Params, false),
        card_id    = maps:get(<<"card_id">>, Params, undefined),
        card_set_id = maps:get(<<"card_set_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #product{
        id         = Record#product.id,
        name       = maps:get(<<"name">>, Params, Record#product.name),
        product_type = maps:get(<<"product_type">>, Params, Record#product.product_type),
        price      = maps:get(<<"price">>, Params, Record#product.price),
        stock      = maps:get(<<"stock">>, Params, Record#product.stock),
        active     = maps:get(<<"active">>, Params, Record#product.active),
        discount_percent = maps:get(<<"discount_percent">>, Params, Record#product.discount_percent),
        description = maps:get(<<"description">>, Params, Record#product.description),
        image_url  = maps:get(<<"image_url">>, Params, Record#product.image_url),
        featured   = maps:get(<<"featured">>, Params, Record#product.featured),
        card_id    = maps:get(<<"card_id">>, Params, Record#product.card_id),
        card_set_id = maps:get(<<"card_set_id">>, Params, Record#product.card_set_id),
        created_at = Record#product.created_at,
        updated_at = iso_now()
    }.

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

validate_product_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"price">>, M, undefined)) > 0) of false -> {true, <<"Product price must be greater than zero">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"stock">>, M, undefined)) >= 0) of false -> {true, <<"Product stock must not be negative">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"discount_percent">>, M, undefined)) >= 0 andalso to_number(maps:get(<<"discount_percent">>, M, undefined)) =< 100) of false -> {true, <<"Product discount percent must be between 0 and 100">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_activate(Req, State) ->
    _ = activate_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

activate_behavior(_Record) ->
    %% TODO: implement activate
    ok.

handle_deactivate(Req, State) ->
    _ = deactivate_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

deactivate_behavior(_Record) ->
    %% TODO: implement deactivate
    ok.

handle_apply_discount(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = apply_discount_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

apply_discount_behavior(_Record, _Params) ->
    %% TODO: implement apply_discount(percent)
    null.

handle_restock(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = restock_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

restock_behavior(_Record, _Params) ->
    %% TODO: implement restock(quantity)
    ok.

handle_effective_price(Req, State) ->
    Result = effective_price_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

effective_price_behavior(_Record) ->
    %% TODO: implement effective_price
    null.

handle_is_in_stock(Req, State) ->
    Result = is_in_stock_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

is_in_stock_behavior(_Record) ->
    %% TODO: implement is_in_stock
    null.

