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

    public function outbidBy(int $id, $newAmount): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeBid not found: ' . $id);
        $result = $entity->outbidBy($newAmount);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function retract(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TradeBid not found: ' . $id);
        $entity->retract();
        $this->repository->save($entity, flush: true);
    }
}
