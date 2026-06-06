-module(player_achievement_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_increment_progress/2, handle_complete/2]).

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
            case player_achievement_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

apply_projection(Map) ->
    (fun(M) -> maps:put(earned_at, maps:get(earned_at, M, undefined), maps:remove(earned_at, M)) end)(Map).

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = player_achievement_store:all(),
            Body = jsone:encode(lists:map(fun apply_projection/1, All)),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(apply_projection(State)),
            {Body, Req, State}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_increment_progress(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = increment_progress_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

increment_progress_behavior(_Record, _Params) ->
    %% TODO: implement increment_progress(amount)
    ok.

handle_complete(Req, State) ->
    _ = complete_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

complete_behavior(_Record) ->
    %% TODO: implement complete
    ok.

