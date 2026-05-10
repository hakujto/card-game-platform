<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CardPriceHistoryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'price_date' => $this->price_date,
            'avg_price' => $this->avg_price,
            'min_price' => $this->min_price,
            'max_price' => $this->max_price,
            'volume' => $this->volume,
            'foil' => $this->foil,
            'card_id' => $this->card_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
