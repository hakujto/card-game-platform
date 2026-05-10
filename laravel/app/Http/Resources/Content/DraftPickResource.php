<?php

namespace App\Http\Resources\Content;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DraftPickResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'pick_number' => $this->pick_number,
            'pack_number' => $this->pack_number,
            'picked_at' => $this->picked_at,
            'participant_id' => $this->participant_id,
            'card_id' => $this->card_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
