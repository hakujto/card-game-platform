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
}
