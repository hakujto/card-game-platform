-module(trade_transaction_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_complete/2, handle_refund/2, handle_open_dispute/2, handle_seller_net/2]).

-include("records.hrl").
-include("marketplace_events.hrl").

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
            case trade_transaction_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(completed_at, maps:get(completed_at, M, undefined), maps:remove(completed_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = trade_transaction_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

record_to_map(#trade_transaction{id = Id, final_price = FinalPrice, platform_fee = PlatformFee, status = Status, completed_at = CompletedAt, listing_id = ListingId, buyer_id = BuyerId, seller_id = SellerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"final_price">> => FinalPrice,
        <<"platform_fee">> => PlatformFee,
        <<"status">> => Status,
        <<"completed_at">> => CompletedAt,
        <<"listing_id">> => ListingId,
        <<"buyer_id">> => BuyerId,
        <<"seller_id">> => SellerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

%% ── Audit log ───────────────────────────────────────────────────────
write_trade_transaction_audit_log(Record, Action) ->
    AuditId = erlang:unique_integer([positive]),
    AuditRecord = #trade_transaction_audit_log{
        id         = AuditId,
        record_id  = maps:get(<<"id">>, record_to_map(Record), undefined),
        action     = Action,
        actor      = undefined,
        changes    = jsone:encode(record_to_map(Record)),
        inserted_at = iso_now()
    },
    F = fun() -> mnesia:write(AuditRecord) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_complete(Req, State) ->
    _ = complete_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

complete_behavior(_Record) ->
    %% TODO: implement complete
    ok.

handle_refund(Req, State) ->
    _ = refund_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

refund_behavior(_Record) ->
    %% TODO: implement refund
    ok.

handle_open_dispute(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = open_dispute_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

open_dispute_behavior(_Record, _Params) ->
    %% TODO: implement open_dispute(reason)
    ok.

handle_seller_net(Req, State) ->
    Result = seller_net_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

seller_net_behavior(_Record) ->
    %% TODO: implement seller_net
    null.

