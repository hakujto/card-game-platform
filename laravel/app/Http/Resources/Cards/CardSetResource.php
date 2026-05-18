<?php

namespace App\Http\Resources\Cards;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CardSetResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'release_date' => $this->release_date,
            'rotation_date' => $this->rotation_date,
            'set_type' => $this->set_type,
            'total_cards' => $this->total_cards,
            'is_rotated' => $this->is_rotated,
            'description' => $this->description,
            'logo_url' => $this->logo_url,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
