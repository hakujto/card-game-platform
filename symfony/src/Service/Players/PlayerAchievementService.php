<?php

namespace App\Service\Players;

use App\Entity\Players\PlayerAchievement;
use App\Repository\Players\PlayerAchievementRepository;

class PlayerAchievementService
{
    public function __construct(
        private PlayerAchievementRepository $repository,
    ) {}

    public function create(array $data): PlayerAchievement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerAchievement $entity, array $data): PlayerAchievement
    {
        throw new \LogicException('Not implemented');
    }

    public function incrementProgress(int $id, $amount): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerAchievement not found: ' . $id);
        $entity->incrementProgress($amount);
        $this->repository->save($entity, flush: true);
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerAchievement not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }

    public function setIsCompleted(int $id, string $value): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerAchievement not found: ' . $id);
        $entity->setIsCompleted($value);
        if ($value === 'TRUE') {
            $entity->complete(); // @on(is_completed = true)
        }
        $this->repository->save($entity, flush: true);
    }
}
