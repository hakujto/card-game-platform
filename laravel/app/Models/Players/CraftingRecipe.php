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

}
