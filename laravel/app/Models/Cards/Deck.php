<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class Deck extends Model
{
    protected $table = 'decks';

    protected $fillable = ['name', 'description', 'format', 'is_public', 'is_tournament_legal', 'archetype', 'wins', 'losses', 'player_id'];

    protected $casts = [
        'is_public' => 'boolean',
        'is_tournament_legal' => 'boolean',
    ];

    const FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];
    const ARCHETYPE_VALUES = ['Aggro', 'Control', 'Midrange', 'Combo', 'Prison', 'Tempo'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function cardses(): BelongsToMany
    {
        return $this->belongsToMany(Card::class, 'deck_cards_pivot', 'deck_id', 'card_id');
    }

    public function sideboardCardses(): BelongsToMany
    {
        return $this->belongsToMany(Card::class, 'deck_sideboard_cards_pivot', 'deck_id', 'card_id');
    }

    public function tagses(): BelongsToMany
    {
        return $this->belongsToMany(DeckTag::class, 'deck_tags_pivot', 'deck_id', 'deck_tag_id');
    }

}
