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

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->mana_cost === null || ($this->mana_cost >= 0 && $this->mana_cost <= 20)))) {
            $errors['mana_cost_range'] = 'mana_cost must be between 0 and 20';
        }
        if (!(($this->power_level === null || ($this->power_level >= 1 && $this->power_level <= 10)))) {
            $errors['power_level_range'] = 'power_level must be between 1 and 10';
        }
        if (!(!(($this->is_banned === true && $this->is_restricted === true)))) {
            $errors['not_banned_and_restricted'] = 'Card cannot be both banned and restricted at the same time';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->card_type === 'Creature' && !($this->attack !== null && $this->defense !== null)) {
            throw new \RuntimeException('Creature card must have attack and defense');
        }
        if ($this->card_type === 'Planeswalker' && $this->loyalty === null) {
            throw new \RuntimeException('Planeswalker card must have loyalty');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function ban(): void
    {
        throw new \RuntimeException('ban not implemented');
    }

    public function unban(): void
    {
        throw new \RuntimeException('unban not implemented');
    }

    public function restrict(): void
    {
        throw new \RuntimeException('restrict not implemented');
    }

    public function unrestrict(): void
    {
        throw new \RuntimeException('unrestrict not implemented');
    }

    public function calculateValue(): string
    {
        throw new \RuntimeException('calculate_value not implemented');
    }

}
