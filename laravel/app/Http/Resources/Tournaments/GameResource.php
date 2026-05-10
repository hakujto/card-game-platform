<?php

namespace App\Http\Resources\Tournaments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GameResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'game_number' => $this->game_number,
            'winner_side' => $this->winner_side,
            'turns_played' => $this->turns_played,
            'duration_seconds' => $this->duration_seconds,
            'ended_by' => $this->ended_by,
            'replay_url' => $this->replay_url,
            'match_id' => $this->match_id,
            'winner_id' => $this->winner_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
