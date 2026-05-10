<?php

namespace App\Http\Resources\Marketplace;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'product_type' => $this->product_type,
            'price' => $this->price,
            'stock' => $this->stock,
            'active' => $this->active,
            'discount_percent' => $this->discount_percent,
            'description' => $this->description,
            'image_url' => $this->image_url,
            'featured' => $this->featured,
            'card_id' => $this->card_id,
            'card_set_id' => $this->card_set_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
