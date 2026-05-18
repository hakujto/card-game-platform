<?php

namespace App\Service\Players;

use App\Entity\Players\PlayerSeasonStats;
use App\Repository\Players\PlayerSeasonStatsRepository;

class PlayerSeasonStatsService
{
    public function __construct(
        private PlayerSeasonStatsRepository $repository,
    ) {}

    public function create(array $data): PlayerSeasonStats
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerSeasonStats $entity, array $data): PlayerSeasonStats
    {
        throw new \LogicException('Not implemented');
    }

    public function winRate(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerSeasonStats not found: ' . $id);
        $result = $entity->winRate();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function addPoints(int $id, $points): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerSeasonStats not found: ' . $id);
        $entity->addPoints($points);
        $this->repository->save($entity, flush: true);
    }

    public function recordTournamentWin(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('PlayerSeasonStats not found: ' . $id);
        $entity->recordTournamentWin();
        $this->repository->save($entity, flush: true);
    }
}
