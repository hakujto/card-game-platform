-module(tournament_judge_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, handle_delete/2, delete_resource/2, handle_promote_to_head/2, handle_remove/2]).

-include("records.hrl").

init(Req, State) ->
    {cowboy_rest, Req, State}.

allowed_methods(Req, State) ->
    {[<<"POST">>, <<"GET">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, handle_get}], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, handle_post}], Req, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined -> {true, Req, State};
        Id ->
            case tournament_judge_store:find(binary_to_integer(Id)) of
                {ok, Record} -> {true, Req, Record};
                not_found    -> {false, Req, State}
            end
    end.

handle_get(Req, State) ->
    case cowboy_req:binding(id, Req) of
        undefined ->
            All  = tournament_judge_store:all(),
            Body = jsone:encode(All),
            {Body, Req, State};
        _Id ->
            Body = jsone:encode(State),
            {Body, Req, State}
    end.

handle_post(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Id     = tournament_judge_store:next_id(),
    Record = params_to_record(Id, Params),
    ok     = tournament_judge_store:insert(Record),
    Resp   = jsone:encode(record_to_map(Record)),
    Req2   = cowboy_req:reply(201, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, State}
.

handle_delete(Req, State) ->
    delete_resource(Req, State).

delete_resource(Req, State) ->
    ok = tournament_judge_store:delete(maps:get(<<"id">>, State)),
    {true, Req, State}.

params_to_record(Id, Params) ->
    #tournament_judge{
        id         = Id,
        role       = maps:get(<<"role">>, Params, <<"Judge">>),
        tournament_id = maps:get(<<"tournament_id">>, Params, undefined),
        player_id  = maps:get(<<"player_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

record_to_map(#tournament_judge{id = Id, role = Role, tournament_id = TournamentId, player_id = PlayerId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"role">> => Role,
        <<"tournament_id">> => TournamentId,
        <<"player_id">> => PlayerId,
        <<"created_at">> => CreatedAt,
        <<"updated_at">> => UpdatedAt
    }.

iso_now() ->
    {{Y,Mo,D},{H,Mi,S}} = calendar:universal_time(),
    iolist_to_binary(io_lib:format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0BZ", [Y,Mo,D,H,Mi,S])).

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_promote_to_head(Req, State) ->
    _ = promote_to_head_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

promote_to_head_behavior(_Record) ->
    %% TODO: implement promote_to_head
    ok.

handle_remove(Req, State) ->
    _ = remove_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

remove_behavior(_Record) ->
    %% TODO: implement remove
    ok.

