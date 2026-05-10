<?php

namespace App\Http\Resources\Players;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CraftingIngredientResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'quantity' => $this->quantity,
            'recipe_id' => $this->recipe_id,
            'card_id' => $this->card_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
