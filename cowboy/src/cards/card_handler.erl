-module(card_handler).
-behaviour(cowboy_rest).

-export([init/2, allowed_methods/2, content_types_provided/2, content_types_accepted/2, resource_exists/2, handle_get/2, handle_post/2, allow_missing_post/2, handle_put/2, handle_patch/2, handle_ban/2, handle_unban/2, handle_restrict/2, handle_unrestrict/2, handle_calculate_value/2, handle_apply_rarity_bonus/2, handle_is_legal_in_format/2]).

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
            case card_store:find(binary_to_integer(Id)) of
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
            All = card_store:all(),
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
    case validate_card_rules(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    case validate_card_implies(Params) of {error, Errs} -> reply_422(Req1, Errs, State); ok ->
    Id     = card_store:next_id(),
    Record = params_to_record(Id, Params),
    Record1 = validate_legality_hook(Record),
    ok     = card_store:insert(Record1),
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
    {ok, ExistingRecord} = card_store:find_record(Id),
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Updated = merge_record(ExistingRecord, Params),
    Updated1 = validate_legality_hook(Updated),
    ok = card_store:update(Updated1),
    Resp = jsone:encode(record_to_map(Updated)),
    Req2 = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1),
    {stop, Req2, Updated}
    end.

handle_patch(Req0, State) -> handle_put(Req0, State).

params_to_record(Id, Params) ->
    #card{
        id         = Id,
        name       = maps:get(<<"name">>, Params, undefined),
        card_type  = maps:get(<<"card_type">>, Params, undefined),
        rarity     = maps:get(<<"rarity">>, Params, undefined),
        mana_cost  = maps:get(<<"mana_cost">>, Params, undefined),
        mana_colors = maps:get(<<"mana_colors">>, Params, undefined),
        attack     = maps:get(<<"attack">>, Params, undefined),
        defense    = maps:get(<<"defense">>, Params, undefined),
        loyalty    = maps:get(<<"loyalty">>, Params, undefined),
        description = maps:get(<<"description">>, Params, undefined),
        flavor_text = maps:get(<<"flavor_text">>, Params, undefined),
        image_url  = maps:get(<<"image_url">>, Params, undefined),
        artist_name = maps:get(<<"artist_name">>, Params, undefined),
        legal_formats = maps:get(<<"legal_formats">>, Params, undefined),
        is_banned  = maps:get(<<"is_banned">>, Params, undefined),
        is_restricted = maps:get(<<"is_restricted">>, Params, undefined),
        power_level = maps:get(<<"power_level">>, Params, undefined),
        set_id     = maps:get(<<"set_id">>, Params, undefined),
        created_at = iso_now(),
        updated_at = iso_now()
    }.

merge_record(Record, Params) ->
    #card{
        id         = Record#card.id,
        name       = maps:get(<<"name">>, Params, Record#card.name),
        card_type  = maps:get(<<"card_type">>, Params, Record#card.card_type),
        rarity     = maps:get(<<"rarity">>, Params, Record#card.rarity),
        mana_cost  = maps:get(<<"mana_cost">>, Params, Record#card.mana_cost),
        mana_colors = maps:get(<<"mana_colors">>, Params, Record#card.mana_colors),
        attack     = maps:get(<<"attack">>, Params, Record#card.attack),
        defense    = maps:get(<<"defense">>, Params, Record#card.defense),
        loyalty    = maps:get(<<"loyalty">>, Params, Record#card.loyalty),
        description = maps:get(<<"description">>, Params, Record#card.description),
        flavor_text = maps:get(<<"flavor_text">>, Params, Record#card.flavor_text),
        image_url  = maps:get(<<"image_url">>, Params, Record#card.image_url),
        artist_name = maps:get(<<"artist_name">>, Params, Record#card.artist_name),
        legal_formats = maps:get(<<"legal_formats">>, Params, Record#card.legal_formats),
        is_banned  = maps:get(<<"is_banned">>, Params, Record#card.is_banned),
        is_restricted = maps:get(<<"is_restricted">>, Params, Record#card.is_restricted),
        power_level = maps:get(<<"power_level">>, Params, Record#card.power_level),
        set_id     = maps:get(<<"set_id">>, Params, Record#card.set_id),
        created_at = Record#card.created_at,
        updated_at = iso_now()
    }.

record_to_map(#card{id = Id, name = Name, card_type = CardType, rarity = Rarity, mana_cost = ManaCost, mana_colors = ManaColors, attack = Attack, defense = Defense, loyalty = Loyalty, description = Description, flavor_text = FlavorText, image_url = ImageUrl, artist_name = ArtistName, legal_formats = LegalFormats, is_banned = IsBanned, is_restricted = IsRestricted, power_level = PowerLevel, set_id = SetId, created_at = CreatedAt, updated_at = UpdatedAt}) ->
    #{
        <<"id">> => Id,
        <<"name">> => Name,
        <<"card_type">> => CardType,
        <<"rarity">> => Rarity,
        <<"mana_cost">> => ManaCost,
        <<"mana_colors">> => ManaColors,
        <<"attack">> => Attack,
        <<"defense">> => Defense,
        <<"loyalty">> => Loyalty,
        <<"description">> => Description,
        <<"flavor_text">> => FlavorText,
        <<"image_url">> => ImageUrl,
        <<"artist_name">> => ArtistName,
        <<"legal_formats">> => LegalFormats,
        <<"is_banned">> => IsBanned,
        <<"is_restricted">> => IsRestricted,
        <<"power_level">> => PowerLevel,
        <<"set_id">> => SetId,
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

%% ── Lifecycle hooks ──────────────────────────────────────────────────
validate_legality_hook(Record) ->
    %% TODO: implement validate_legality
    Record.

to_number(V) when is_integer(V) -> float(V);
to_number(V) when is_float(V)   -> V;
to_number(V) when is_binary(V)  ->
    try binary_to_float(V) catch _:_ -> try float(binary_to_integer(V)) catch _:_ -> 0.0 end end;
to_number(_)                    -> 0.0.

validate_card_rules(M) ->
    Checks = [
        fun() -> case (to_number(maps:get(<<"mana_cost">>, M, undefined)) >= 0 andalso to_number(maps:get(<<"mana_cost">>, M, undefined)) =< 20) of false -> {true, <<"mana_cost must be between 0 and 20">>}; _ -> false end end,
        fun() -> case (to_number(maps:get(<<"power_level">>, M, undefined)) >= 1 andalso to_number(maps:get(<<"power_level">>, M, undefined)) =< 10) of false -> {true, <<"power_level must be between 1 and 10">>}; _ -> false end end,
        fun() -> case (not (((maps:get(<<"is_banned">>, M, undefined) =:= true) andalso (maps:get(<<"is_restricted">>, M, undefined) =:= true)))) of false -> {true, <<"Card cannot be both banned and restricted at the same time">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

validate_card_implies(M) ->
    Checks = [
        fun() -> case ((maps:get(<<"card_type">>, M, undefined) =:= <<"Creature">>)) andalso not (((maps:get(<<"attack">>, M, undefined) =/= undefined andalso maps:get(<<"attack">>, M, undefined) =/= null) andalso (maps:get(<<"defense">>, M, undefined) =/= undefined andalso maps:get(<<"defense">>, M, undefined) =/= null))) of true -> {true, <<"Creature card must have attack and defense">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"card_type">>, M, undefined) =:= <<"Planeswalker">>)) andalso not ((maps:get(<<"loyalty">>, M, undefined) =/= undefined andalso maps:get(<<"loyalty">>, M, undefined) =/= null)) of true -> {true, <<"Planeswalker card must have loyalty">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"card_type">>, M, undefined) =:= <<"Land">>)) andalso not ((maps:get(<<"mana_cost">>, M, undefined) =:= 0)) of true -> {true, <<"Land card must have zero mana cost">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"card_type">>, M, undefined) =/= <<"Planeswalker">>)) andalso not ((maps:get(<<"loyalty">>, M, undefined) =:= undefined orelse maps:get(<<"loyalty">>, M, undefined) =:= null)) of true -> {true, <<"Only Planeswalker cards can have loyalty">>}; _ -> false end end,
        fun() -> case ((maps:get(<<"is_banned">>, M, undefined) =:= true)) andalso not ((maps:get(<<"legal_formats">>, M, undefined) =:= <<"message">>)) of true -> {true, <<"banned_card_not_in_legal_formats">>}; _ -> false end end
    ],
    Errors = lists:filtermap(fun(F) -> F() end, Checks),
    case Errors of
        [] -> ok;
        _  -> {error, Errors}
    end.

%% ── Behavior endpoints ──────────────────────────────────────────────
handle_ban(Req, State) ->
    _ = ban_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

ban_behavior(_Record) ->
    %% TODO: implement ban
    ok.

handle_unban(Req, State) ->
    _ = unban_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

unban_behavior(_Record) ->
    %% TODO: implement unban
    ok.

handle_restrict(Req, State) ->
    _ = restrict_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

restrict_behavior(_Record) ->
    %% TODO: implement restrict
    ok.

handle_unrestrict(Req, State) ->
    _ = unrestrict_behavior(State),
    {true, cowboy_req:reply(204, #{}, <<>>, Req), State}.

unrestrict_behavior(_Record) ->
    %% TODO: implement unrestrict
    ok.

handle_calculate_value(Req, State) ->
    Result = calculate_value_behavior(State),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req), State}.

calculate_value_behavior(_Record) ->
    %% TODO: implement calculate_value
    null.

handle_apply_rarity_bonus(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = apply_rarity_bonus_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

apply_rarity_bonus_behavior(_Record, _Params) ->
    %% TODO: implement apply_rarity_bonus(multiplier)
    null.

handle_is_legal_in_format(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    Params = jsone:decode(Body, [{object_format, map}]),
    Result = is_legal_in_format_behavior(State, Params),
    Resp = jsone:encode(#{<<"result">> => Result}),
    {true, cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Resp, Req1), State}.

is_legal_in_format_behavior(_Record, _Params) ->
    %% TODO: implement is_legal_in_format(format)
    null.

