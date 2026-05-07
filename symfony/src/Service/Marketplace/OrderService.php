<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\Order;
use App\Repository\Marketplace\OrderRepository;

class OrderService
{
    public function __construct(
        private OrderRepository $repository,
    ) {}

    public function create(array $data): Order
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Order $entity, array $data): Order
    {
        throw new \LogicException('Not implemented');
    }
}
