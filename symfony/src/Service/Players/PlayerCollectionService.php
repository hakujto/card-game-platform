<?php

namespace App\Service\Players;

use App\Entity\Players\PlayerCollection;
use App\Repository\Players\PlayerCollectionRepository;

class PlayerCollectionService
{
    public function __construct(
        private PlayerCollectionRepository $repository,
    ) {}

    public function create(array $data): PlayerCollection
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerCollection $entity, array $data): PlayerCollection
    {
        throw new \LogicException('Not implemented');
    }

    public function add(int $id, $quantity): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerCollection not found: ' . $id);
        $entity->add($quantity);
        $this->repository->save($entity, flush: true);
    }

    public function remove(int $id, $quantity): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerCollection not found: ' . $id);
        $entity->remove($quantity);
        $this->repository->save($entity, flush: true);
    }

    public function estimatedValue(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerCollection not found: ' . $id);
        $result = $entity->estimatedValue();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
