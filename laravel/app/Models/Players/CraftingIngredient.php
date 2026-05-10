<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Cards\Card;

class CraftingIngredient extends Model
{
    protected $table = 'crafting_ingredients';

    protected $fillable = ['quantity', 'recipe_id', 'card_id'];

    public function recipe(): BelongsTo
    {
        return $this->belongsTo(CraftingRecipe::class, 'recipe_id');
    }

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

}
