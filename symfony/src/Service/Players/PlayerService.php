<?php

namespace App\Service\Players;

use App\Entity\Players\Player;
use App\Repository\Players\PlayerRepository;

class PlayerService
{
    public function __construct(
        private PlayerRepository $repository,
    ) {}

    public function create(array $data): Player
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Player $entity, array $data): Player
    {
        throw new \LogicException('Not implemented');
    }

    public function promote(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $result = $entity->promote();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function demote(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $result = $entity->demote();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function recordWin(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $entity->recordWin();
        $this->repository->save($entity, flush: true);
    }

    public function recordLoss(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $entity->recordLoss();
        $this->repository->save($entity, flush: true);
    }

    public function winRate(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $result = $entity->winRate();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function verify(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $entity->verify();
        $this->repository->save($entity, flush: true);
    }

    public function updateRating(int $id, $delta): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Player not found: ' . $id);
        $entity->updateRating($delta);
        $this->repository->save($entity, flush: true);
    }
}
