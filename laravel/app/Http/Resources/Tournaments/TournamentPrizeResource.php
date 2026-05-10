<?php

namespace App\Http\Resources\Tournaments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TournamentPrizeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'placement_from' => $this->placement_from,
            'placement_to' => $this->placement_to,
            'prize_type' => $this->prize_type,
            'amount' => $this->amount,
            'description' => $this->description,
            'packs_count' => $this->packs_count,
            'season_points' => $this->season_points,
            'tournament_id' => $this->tournament_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
