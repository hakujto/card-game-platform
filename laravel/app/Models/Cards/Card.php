<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use App\Models\Players\PlayerCollection;
use App\Models\Players\CraftingRecipe;
use App\Models\Players\CraftingIngredient;
use App\Models\Marketplace\Product;
use App\Models\Marketplace\TradeListing;
use App\Models\Marketplace\CardPriceHistory;
use App\Models\Content\DraftPick;

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

    public function rulings(): HasMany
    {
        return $this->hasMany(CardRuling::class, 'card_id');
    }

    public function abilities(): HasMany
    {
        return $this->hasMany(CardAbility::class, 'card_id');
    }

    public function deckCards(): HasMany
    {
        return $this->hasMany(DeckCard::class, 'card_id');
    }

    public function sideboardDecks(): HasMany
    {
        return $this->hasMany(DeckSideboardCard::class, 'card_id');
    }

    public function playerCollections(): HasMany
    {
        return $this->hasMany(PlayerCollection::class, 'card_id');
    }

    public function craftingRecipes(): HasMany
    {
        return $this->hasMany(CraftingRecipe::class, 'result_card_id');
    }

    public function usedInRecipes(): HasMany
    {
        return $this->hasMany(CraftingIngredient::class, 'card_id');
    }

    public function shopProduct(): HasOne
    {
        return $this->hasOne(Product::class, 'card_id');
    }

    public function tradeListings(): HasMany
    {
        return $this->hasMany(TradeListing::class, 'card_id');
    }

    public function priceHistory(): HasMany
    {
        return $this->hasMany(CardPriceHistory::class, 'card_id');
    }

    public function draftPicks(): HasMany
    {
        return $this->hasMany(DraftPick::class, 'card_id');
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
        if ($this->card_type === 'Land' && !($this->mana_cost === 0)) {
            throw new \RuntimeException('Land card must have zero mana cost');
        }
        if ($this->card_type !== 'Planeswalker' && $this->loyalty !== null) {
            throw new \RuntimeException('Only Planeswalker cards can have loyalty');
        }
        if ($this->is_banned === true && !($this->legal_formats === "message")) {
            throw new \RuntimeException('banned_card_not_in_legal_formats');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function ban(): void
    {
        // TODO: implement ban
    }

    public function unban(): void
    {
        // TODO: implement unban
    }

    public function restrict(): void
    {
        // TODO: implement restrict
    }

    public function unrestrict(): void
    {
        // TODO: implement unrestrict
    }

    public function calculateValue(): ?string
    {
        // TODO: implement calculate_value
        return null;
    }

    public function applyRarityBonus($multiplier): ?string
    {
        // TODO: implement apply_rarity_bonus
        return null;
    }

    public function isLegalInFormat($format): ?bool
    {
        // TODO: implement is_legal_in_format
        return null;
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    protected static function boot(): void
    {
        parent::boot();
        static::saving(function (self $model) {
            $model->validateLegality();
        });
        static::deleting(function (self $model) {
            $model->validateNotInUse();
        });
    }

    protected function validateLegality(): void
    {
        // TODO: implement validate_legality
    }

    protected function validateNotInUse(): void
    {
        // TODO: implement validate_not_in_use
    }

}
