<?php

namespace App\Service\Players;

use App\Entity\Players\Achievement;
use App\Repository\Players\AchievementRepository;

class AchievementService
{
    public function __construct(
        private AchievementRepository $repository,
    ) {}

    public function create(array $data): Achievement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Achievement $entity, array $data): Achievement
    {
        throw new \LogicException('Not implemented');
    }

    public function pointValue(int $id, $multiplier): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Achievement not found: ' . $id);
        $result = $entity->pointValue($multiplier);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function reveal(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Achievement not found: ' . $id);
        $entity->reveal();
        $this->repository->save($entity, flush: true);
    }
}
