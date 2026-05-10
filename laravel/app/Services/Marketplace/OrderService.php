<?php

namespace App\Services\Marketplace;

use App\Models\Marketplace\Order;

class OrderService
{
    public function create(array $data): Order
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Order $order, array $data): Order
    {
        throw new \LogicException('Not implemented');
    }
}
