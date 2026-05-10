<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TradelistingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'listing_type' => $this->listing_type,
            'asking_price' => $this->asking_price,
            'auction_start_price' => $this->auction_start_price,
            'auction_current_bid' => $this->auction_current_bid,
            'auction_end_time' => $this->auction_end_time,
            'foil' => $this->foil,
            'condition' => $this->condition,
            'quantity' => $this->quantity,
            'status' => $this->status,
            'description' => $this->description,
            'created_at' => $this->created_at,
            'expires_at' => $this->expires_at,
            'seller_id' => $this->seller_id,
            'card_id' => $this->card_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
