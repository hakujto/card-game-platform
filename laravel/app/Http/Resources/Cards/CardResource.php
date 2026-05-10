<?php

namespace App\Http\Resources\Cards;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'card_type' => $this->card_type,
            'rarity' => $this->rarity,
            'mana_cost' => $this->mana_cost,
            'mana_colors' => $this->mana_colors,
            'attack' => $this->attack,
            'defense' => $this->defense,
            'loyalty' => $this->loyalty,
            'description' => $this->description,
            'flavor_text' => $this->flavor_text,
            'image_url' => $this->image_url,
            'artist_name' => $this->artist_name,
            'legal_formats' => $this->legal_formats,
            'is_banned' => $this->is_banned,
            'is_restricted' => $this->is_restricted,
            'power_level' => $this->power_level,
            'set_id' => $this->set_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
