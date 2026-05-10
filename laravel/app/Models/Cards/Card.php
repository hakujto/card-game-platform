<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Card extends Model
{
    protected $table = 'cards';

    protected $fillable = ['name', 'card_type', 'rarity', 'mana_cost', 'mana_colors', 'attack', 'defense', 'loyalty', 'description', 'flavor_text', 'image_url', 'artist_name', 'legal_formats', 'is_banned', 'is_restricted', 'power_level', 'set_id'];

    protected $casts = [
        'is_banned' => 'boolean',
        'is_restricted' => 'boolean',
    ];

    const CARD_TYPE_VALUES = ['Creature', 'Spell', 'Land', 'Artifact', 'Enchantment', 'Planeswalker'];
    const RARITY_VALUES = ['Common', 'Uncommon', 'Rare', 'MythicRare', 'Legendary'];
    const MANA_COLORS_VALUES = ['White', 'Blue', 'Black', 'Red', 'Green', 'Colorless'];
    const LEGAL_FORMATS_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];

    public function set(): BelongsTo
    {
        return $this->belongsTo(CardSet::class, 'set_id');
    }

}
