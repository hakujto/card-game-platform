<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\OrderItem;
use App\Repository\Marketplace\OrderItemRepository;

class OrderItemService
{
    public function __construct(
        private OrderItemRepository $repository,
    ) {}

    public function create(array $data): OrderItem
    {
        throw new \LogicException('Not implemented');
    }

    public function update(OrderItem $entity, array $data): OrderItem
    {
        throw new \LogicException('Not implemented');
    }

}
