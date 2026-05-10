<?php

namespace App\Http\Resources\Players;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PlayerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'display_name' => $this->display_name,
            'rank' => $this->rank,
            'rating' => $this->rating,
            'peak_rating' => $this->peak_rating,
            'bio' => $this->bio,
            'country_code' => $this->country_code,
            'avatar_url' => $this->avatar_url,
            'preferred_format' => $this->preferred_format,
            'is_verified' => $this->is_verified,
            'created_at' => $this->created_at,
            'last_active_at' => $this->last_active_at,
            'user_id' => $this->user_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
