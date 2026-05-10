<?php

namespace App\Http\Resources\Tournaments;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MatchRecordResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'table_number' => $this->table_number,
            'status' => $this->status,
            'player1_wins' => $this->player1_wins,
            'player2_wins' => $this->player2_wins,
            'started_at' => $this->started_at,
            'ended_at' => $this->ended_at,
            'result_notes' => $this->result_notes,
            'round_id' => $this->round_id,
            'player1_id' => $this->player1_id,
            'player2_id' => $this->player2_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
