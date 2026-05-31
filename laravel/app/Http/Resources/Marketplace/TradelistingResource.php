<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TradeListingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'listing_type' => $this->listing_type,
            'asking_price' => $this->asking_price,
            'auction_start_price' => $this->auction_start_price,
            'auction_current_bid' => $this->auction_current_bid,
            'auctionEndTime' => $this->auction_end_time,
            'foil' => $this->foil,
            'condition' => $this->condition,
            'quantity' => $this->quantity,
            'description' => $this->description,
            'createdAt' => $this->created_at,
            'expiresAt' => $this->expires_at,
            'seller_id' => $this->seller_id,
            'card_id' => $this->card_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
