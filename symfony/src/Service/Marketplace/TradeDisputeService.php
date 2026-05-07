<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeDispute;
use App\Repository\Marketplace\TradeDisputeRepository;

class TradeDisputeService
{
    public function __construct(
        private TradeDisputeRepository $repository,
    ) {}

    public function create(array $data): TradeDispute
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeDispute $entity, array $data): TradeDispute
    {
        throw new \LogicException('Not implemented');
    }
}
