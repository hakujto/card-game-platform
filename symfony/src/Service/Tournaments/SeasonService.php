<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\Season;
use App\Repository\Tournaments\SeasonRepository;

class SeasonService
{
    public function __construct(
        private SeasonRepository $repository,
    ) {}

    public function create(array $data): Season
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Season $entity, array $data): Season
    {
        throw new \LogicException('Not implemented');
    }

    public function activate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Season not found: ' . $id);
        $entity->activate();
        $this->repository->save($entity, flush: true);
    }

    public function deactivate(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Season not found: ' . $id);
        $entity->deactivate();
        $this->repository->save($entity, flush: true);
    }

    public function finalizeRewards(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('Season not found: ' . $id);
        $entity->finalizeRewards();
        $this->repository->save($entity, flush: true);
    }
}
