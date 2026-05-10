<?php

namespace App\Http\Resources\Players;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlayerAchievementResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'earned_at' => $this->earned_at,
            'progress' => $this->progress,
            'is_completed' => $this->is_completed,
            'player_id' => $this->player_id,
            'achievement_id' => $this->achievement_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
