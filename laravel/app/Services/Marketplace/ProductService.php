<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\Product;

class ProductService
{
    public function create(array $data): Product
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Product $product, array $data): Product
    {
        throw new \LogicException('Not implemented');
    }
}
