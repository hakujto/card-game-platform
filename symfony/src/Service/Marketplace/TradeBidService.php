<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeBid;
use App\Repository\Marketplace\TradeBidRepository;

class TradeBidService
{
    public function __construct(
        private TradeBidRepository $repository,
    ) {}

    public function create(array $data): TradeBid
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeBid $entity, array $data): TradeBid
    {
        throw new \LogicException('Not implemented');
    }
}
