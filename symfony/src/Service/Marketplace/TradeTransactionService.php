<?php

namespace App\Service\Marketplace;

use App\Entity\Marketplace\TradeTransaction;
use App\Repository\Marketplace\TradeTransactionRepository;

class TradeTransactionService
{
    public function __construct(
        private TradeTransactionRepository $repository,
    ) {}

    public function create(array $data): TradeTransaction
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TradeTransaction $entity, array $data): TradeTransaction
    {
        throw new \LogicException('Not implemented');
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeTransaction not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }

    public function refund(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeTransaction not found: ' . $id);
        $entity->refund();
        $this->repository->save($entity, flush: true);
    }

    public function openDispute(int $id, $reason): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeTransaction not found: ' . $id);
        $entity->openDispute($reason);
        $this->repository->save($entity, flush: true);
    }

    public function sellerNet(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeTransaction not found: ' . $id);
        $result = $entity->sellerNet();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
