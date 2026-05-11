<?php

namespace App\Service\Economy;

use App\Entity\Economy\TopUpOrder;
use App\Repository\Economy\TopUpOrderRepository;

class TopUpOrderService
{
    public function __construct(
        private TopUpOrderRepository $repository,
    ) {}

    public function create(array $data): TopUpOrder
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TopUpOrder $entity, array $data): TopUpOrder
    {
        throw new \LogicException('Not implemented');
    }
}
