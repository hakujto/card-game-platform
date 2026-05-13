<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\CardPriceHistory;
use App\Repository\Marketplace\CardPriceHistoryRepository;

class CardPriceHistoryService
{
    public function __construct(
        private CardPriceHistoryRepository $repository,
    ) {}

    public function create(array $data): CardPriceHistory
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardPriceHistory $entity, array $data): CardPriceHistory
    {
        throw new \LogicException('Not implemented');
    }

}
