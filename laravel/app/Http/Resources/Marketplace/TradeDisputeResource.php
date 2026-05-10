<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TradeDisputeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'reason' => $this->reason,
            'description' => $this->description,
            'status' => $this->status,
            'resolution' => $this->resolution,
            'opened_at' => $this->opened_at,
            'resolved_at' => $this->resolved_at,
            'transaction_id' => $this->transaction_id,
            'opened_by_id' => $this->opened_by_id,
            'resolved_by_id' => $this->resolved_by_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
