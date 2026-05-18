<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\TournamentPrize;
use App\Repository\Tournaments\TournamentPrizeRepository;

class TournamentPrizeService
{
    public function __construct(
        private TournamentPrizeRepository $repository,
    ) {}

    public function create(array $data): TournamentPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentPrize $entity, array $data): TournamentPrize
    {
        throw new \LogicException('Not implemented');
    }

    public function appliesToPlacement(int $id, $placement): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentPrize not found: ' . $id);
        $result = $entity->appliesToPlacement($placement);
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function awardToPlayer(int $id, $playerId): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentPrize not found: ' . $id);
        $entity->awardToPlayer($playerId);
        $this->repository->save($entity, flush: true);
    }
}
