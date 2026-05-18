<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class CraftingRecipe extends Model
{
    protected $table = 'crafting_recipes';

    protected $fillable = ['dust_cost', 'is_available', 'result_card_id'];

    protected $casts = [
        'is_available' => 'boolean',
    ];

    public function resultCard(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'result_card_id');
    }

    public function requiredCardses(): BelongsToMany
    {
        return $this->belongsToMany(Card::class, 'crafting_recipe_required_cards_pivot', 'crafting_recipe_id', 'card_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->dust_cost === null || $this->dust_cost > 0))) {
            $errors['dust_cost_positive'] = 'Crafting recipe must have a dust cost greater than zero';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function canCraft($player_id): bool
    {
        throw new \RuntimeException('can_craft not implemented');
    }

    public function executeCraft($player_id): void
    {
        throw new \RuntimeException('execute_craft not implemented');
    }

    public function disable(): void
    {
        throw new \RuntimeException('disable not implemented');
    }

    public function enable(): void
    {
        throw new \RuntimeException('enable not implemented');
    }

}
