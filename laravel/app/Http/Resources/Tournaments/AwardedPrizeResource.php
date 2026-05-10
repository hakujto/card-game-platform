<?php

namespace App\Http\Resources\Tournaments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AwardedPrizeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'final_placement' => $this->final_placement,
            'awarded_at' => $this->awarded_at,
            'claimed' => $this->claimed,
            'claimed_at' => $this->claimed_at,
            'prize_id' => $this->prize_id,
            'player_id' => $this->player_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
