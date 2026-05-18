<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\OrderItem;

class OrderItemService
{
    public function create(array $data): OrderItem
    {
        throw new \LogicException('Not implemented');
    }

    public function update(OrderItem $orderItem, array $data): OrderItem
    {
        throw new \LogicException('Not implemented');
    }
    public function lineTotal(int $id): string
    {
        $orderItem = OrderItem::findOrFail($id);
        $result = $orderItem->lineTotal();
        $orderItem->save();
        return $result;
    }
}
