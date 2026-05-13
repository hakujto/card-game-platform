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

    public function close(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tradelisting not found: ' . $id);
        $entity->close();
        $this->repository->save($entity, flush: true);
    }

    public function extend(int $id, $days): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tradelisting not found: ' . $id);
        $entity->extend($days);
        $this->repository->save($entity, flush: true);
    }

    public function cancel(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tradelisting not found: ' . $id);
        $entity->cancel();
        $this->repository->save($entity, flush: true);
    }

    public function setStatus(int $id, string $value): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tradelisting not found: ' . $id);
        $entity->setStatus($value);
        if ($value === 'SOLD') {
            $entity->finalizeAuction(); // @on(status = Sold)
        }
        $this->repository->save($entity, flush: true);
    }
}
