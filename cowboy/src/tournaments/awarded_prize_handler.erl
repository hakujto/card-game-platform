-module(awarded_prize_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_claim/2]).

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
            case awarded_prize_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(claimed_at, maps:get(claimed_at, M, undefined), maps:remove(claimed_at, M)) end)((fun(M) -> maps:put(awarded_at, maps:get(awarded_at, M, undefined), maps:remove(awarded_at, M)) end)(Map)).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = awarded_prize_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_claim(Req, State) ->
    _ = claim_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

claim_behavior(_Record) ->
    %% TODO: implement claim
    ok.

