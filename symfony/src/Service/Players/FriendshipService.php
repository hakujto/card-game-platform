<?php

namespace App\Service\Players;

use App\Entity\Players\Friendship;
use App\Repository\Players\FriendshipRepository;

class FriendshipService
{
    public function __construct(
        private FriendshipRepository $repository,
    ) {}

    public function create(array $data): Friendship
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Friendship $entity, array $data): Friendship
    {
        throw new \LogicException('Not implemented');
    }

    public function accept(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Friendship not found: ' . $id);
        $entity->accept();
        $this->repository->save($entity, flush: true);
    }

    public function decline(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Friendship not found: ' . $id);
        $entity->decline();
        $this->repository->save($entity, flush: true);
    }

    public function block(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Friendship not found: ' . $id);
        $entity->block();
        $this->repository->save($entity, flush: true);
    }
}
