-module(card_store).
-export([all/0, find/1, find_record/1, insert/1, update/1, delete/1, next_id/0]).

-include("records.hrl").

all() ->
    F = fun() -> mnesia:match_object(#card{_ = '_'}) end,
    {atomic, Records} = mnesia:transaction(F),
    [record_to_map(R) || R <- Records].

find(Id) ->
    F = fun() -> mnesia:read(card, Id) end,
    case mnesia:transaction(F) of
        {atomic, [R]} -> {ok, record_to_map(R)};
        {atomic, []}  -> not_found
    end.

find_record(Id) ->
    F = fun() -> mnesia:read(card, Id) end,
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
    F = fun() -> mnesia:delete({card, Id}) end,
    {atomic, ok} = mnesia:transaction(F),
    ok.

next_id() ->
    mnesia:dirty_update_counter(id_seq, card, 1).

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

