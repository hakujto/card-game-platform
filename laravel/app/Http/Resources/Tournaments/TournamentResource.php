<?php

namespace App\Http\Resources\Tournaments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TournamentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'public_id' => $this->public_id,
            'name' => $this->name,
            'description' => $this->description,
            'status' => $this->status,
            'bracket_data' => $this->bracket_data,
            'format' => $this->format,
            'tournament_type' => $this->tournament_type,
            'max_players' => $this->max_players,
            'entry_fee' => $this->entry_fee,
            'prize_pool' => $this->prize_pool,
            'startTime' => $this->start_time,
            'endTime' => $this->end_time,
            'is_online' => $this->is_online,
            'location' => $this->location,
            'rules_text' => $this->rules_text,
            'createdAt' => $this->created_at,
            'season_id' => $this->season_id,
            'organizer_id' => $this->organizer_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
