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

    public function escalate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->escalate();
        $this->repository->save($entity, flush: true);
    }

    public function resolve(int $id, $resolutionText): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->resolve($resolutionText);
        $this->repository->save($entity, flush: true);
    }

    public function review(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeDispute not found: ' . $id);
        $entity->review();
        $this->repository->save($entity, flush: true);
    }
}
