<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TradeTransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'final_price' => $this->final_price,
            'platform_fee' => $this->platform_fee,
            'status' => $this->status,
            'completed_at' => $this->completed_at,
            'listing_id' => $this->listing_id,
            'buyer_id' => $this->buyer_id,
            'seller_id' => $this->seller_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
