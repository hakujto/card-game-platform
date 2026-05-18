<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\TournamentRound;
use App\Repository\Tournaments\TournamentRoundRepository;

class TournamentRoundService
{
    public function __construct(
        private TournamentRoundRepository $repository,
    ) {}

    public function create(array $data): TournamentRound
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentRound $entity, array $data): TournamentRound
    {
        throw new \LogicException('Not implemented');
    }

    public function start(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRound not found: ' . $id);
        $entity->start();
        $this->repository->save($entity, flush: true);
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRound not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }

    public function generatePairings(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRound not found: ' . $id);
        $entity->generatePairings();
        $this->repository->save($entity, flush: true);
    }

    public function isTimeExpired(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRound not found: ' . $id);
        $result = $entity->isTimeExpired();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
