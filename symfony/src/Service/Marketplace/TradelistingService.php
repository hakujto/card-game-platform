<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\Tradelisting;
use App\Repository\Marketplace\TradelistingRepository;

class TradelistingService
{
    public function __construct(
        private TradelistingRepository $repository,
    ) {}

    public function create(array $data): Tradelisting
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Tradelisting $entity, array $data): Tradelisting
    {
        throw new \LogicException('Not implemented');
    }
}
