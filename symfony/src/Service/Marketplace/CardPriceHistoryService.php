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

    public function priceChangePercent(int $id, $previousAvg): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardPriceHistory not found: ' . $id);
        $result = $entity->priceChangePercent($previousAvg);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function isPriceSpike(int $id, $thresholdPercent): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('CardPriceHistory not found: ' . $id);
        $result = $entity->isPriceSpike($thresholdPercent);
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
