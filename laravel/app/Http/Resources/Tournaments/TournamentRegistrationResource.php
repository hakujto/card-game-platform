<?php

namespace App\Http\Resources\Tournaments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TournamentRegistrationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'seed' => $this->seed,
            'final_standing' => $this->final_standing,
            'points_earned' => $this->points_earned,
            'registered_at' => $this->registered_at,
            'tournament_id' => $this->tournament_id,
            'player_id' => $this->player_id,
            'deck_id' => $this->deck_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
