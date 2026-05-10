<?php

namespace App\Http\Resources\Players;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlayerSeasonStatsResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'wins' => $this->wins,
            'losses' => $this->losses,
            'draws' => $this->draws,
            'tournament_wins' => $this->tournament_wins,
            'highest_rank' => $this->highest_rank,
            'season_points' => $this->season_points,
            'player_id' => $this->player_id,
            'season_id' => $this->season_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
