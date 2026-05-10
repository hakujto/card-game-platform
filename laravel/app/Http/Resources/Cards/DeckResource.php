<?php

namespace App\Http\Resources\Cards;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeckResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'format' => $this->format,
            'is_public' => $this->is_public,
            'is_tournament_legal' => $this->is_tournament_legal,
            'archetype' => $this->archetype,
            'wins' => $this->wins,
            'losses' => $this->losses,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'player_id' => $this->player_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
