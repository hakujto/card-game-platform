<?php

namespace App\Http\Resources\Content;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DraftSessionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'draft_type' => $this->draft_type,
            'seats' => $this->seats,
            'created_at' => $this->created_at,
            'completed_at' => $this->completed_at,
            'card_set_id' => $this->card_set_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
