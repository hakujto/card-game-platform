<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\Tournament;
use App\Repository\Tournaments\TournamentRepository;

class TournamentService
{
    public function __construct(
        private TournamentRepository $repository,
    ) {}

    public function create(array $data): Tournament
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Tournament $entity, array $data): Tournament
    {
        throw new \LogicException('Not implemented');
    }

    public function start(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->start();
        $this->repository->save($entity, flush: true);
    }

    public function cancel(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->cancel();
        $this->repository->save($entity, flush: true);
    }

    public function complete(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->complete();
        $this->repository->save($entity, flush: true);
    }

    public function generateRound(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->generateRound();
        $this->repository->save($entity, flush: true);
    }

    public function calculatePrizeDistribution(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $result = $entity->calculatePrizeDistribution();
        $this->repository->save($entity, flush: true);
        return $result;
    }

    public function registerPlayer(int $id, $playerId, $deckId): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $entity->registerPlayer($playerId, $deckId);
        $this->repository->save($entity, flush: true);
    }

    public function isFull(int $id): mixed
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Tournament not found: ' . $id);
        $result = $entity->isFull();
        $this->repository->save($entity, flush: true);
        return $result;
    }
}
