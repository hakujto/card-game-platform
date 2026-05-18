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
    public function activate(int $id): void
    {
        $product = Product::findOrFail($id);
        $product->activate();
        $product->save();
    }

    public function deactivate(int $id): void
    {
        $product = Product::findOrFail($id);
        $product->deactivate();
        $product->save();
    }

    public function applyDiscount(int $id, $percent): string
    {
        $product = Product::findOrFail($id);
        $result = $product->applyDiscount($percent);
        $product->save();
        return $result;
    }

    public function restock(int $id, $quantity): void
    {
        $product = Product::findOrFail($id);
        $product->restock($quantity);
        $product->save();
    }

    public function effectivePrice(int $id): string
    {
        $product = Product::findOrFail($id);
        $result = $product->effectivePrice();
        $product->save();
        return $result;
    }

    public function isInStock(int $id): bool
    {
        $product = Product::findOrFail($id);
        $result = $product->isInStock();
        $product->save();
        return $result;
    }
}
