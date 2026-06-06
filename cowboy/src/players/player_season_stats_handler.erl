-module(player_season_stats_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_win_rate/2, handle_add_points/2, handle_record_tournament_win/2]).

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
            case player_season_stats_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = player_season_stats_store:all(),
            Body = jsone:encode(All),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_win_rate(Req, State) ->
    Result = win_rate_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

win_rate_behavior(_Record) ->
    %% TODO: implement win_rate
    null.

handle_add_points(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    _ = add_points_behavior(State, Params),
    {true, cowboy_req:reply(204, #{}, <<>>, Req1), State}.

add_points_behavior(_Record, _Params) ->
    %% TODO: implement add_points(points)
    ok.

handle_record_tournament_win(Req, State) ->
    _ = record_tournament_win_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

record_tournament_win_behavior(_Record) ->
    %% TODO: implement record_tournament_win
    ok.

