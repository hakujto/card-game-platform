<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status,
            'total' => $this->total,
            'discount_applied' => $this->discount_applied,
            'currency' => $this->currency,
            'payment_method' => $this->payment_method,
            'payment_reference' => $this->payment_reference,
            'shipping_address' => $this->shipping_address,
            'tracking_number' => $this->tracking_number,
            'created_at' => $this->created_at,
            'paid_at' => $this->paid_at,
            'shipped_at' => $this->shipped_at,
            'player_id' => $this->player_id,
            'coupon_id' => $this->coupon_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
