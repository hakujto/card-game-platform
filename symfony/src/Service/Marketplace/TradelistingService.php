<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeListing;
use App\Repository\Marketplace\TradeListingRepository;

class TradeListingService
{
    public function __construct(
        private TradeListingRepository $repository,
    ) {}

    public function create(array $data): TradeListing
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeListing $entity, array $data): TradeListing
    {
        throw new \LogicException('Not implemented');
    }

    public function close(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->close();
        $this->repository->save($entity, flush: true);
    }

    public function extend(int $id, $days): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->extend($days);
        $this->repository->save($entity, flush: true);
    }

    public function cancel(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->cancel();
        $this->repository->save($entity, flush: true);
    }

    public function isExpired(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $result = $entity->isExpired();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function finalizeAuction(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->finalizeAuction();
        $this->repository->save($entity, flush: true);
    }

    public function setStatus(int $id, string $value): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeListing not found: ' . $id);
        $entity->setStatus($value);
        if ($value === 'SOLD') {
            $entity->finalizeAuction(); // @on(status = Sold)
        }
        $this->repository->save($entity, flush: true);
    }
}
