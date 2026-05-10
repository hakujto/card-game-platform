<?php

namespace App\Http\Resources\Players;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AchievementResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'icon_url' => $this->icon_url,
            'points' => $this->points,
            'rarity' => $this->rarity,
            'is_hidden' => $this->is_hidden,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
