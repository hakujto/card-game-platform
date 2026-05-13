<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\TournamentRegistration;
use App\Repository\Tournaments\TournamentRegistrationRepository;

class TournamentRegistrationService
{
    public function __construct(
        private TournamentRegistrationRepository $repository,
    ) {}

    public function create(array $data): TournamentRegistration
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentRegistration $entity, array $data): TournamentRegistration
    {
        throw new \LogicException('Not implemented');
    }

    public function withdraw(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRegistration not found: ' . $id);
        $entity->withdraw();
        $this->repository->save($entity, flush: true);
    }

    public function disqualify(int $id, $reason): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRegistration not found: ' . $id);
        $entity->disqualify($reason);
        $this->repository->save($entity, flush: true);
    }

    public function promoteFromWaitlist(int $id): void
    {
        $entity = $this->repository->find($id);
        if (!$entity) throw new \RuntimeException('TournamentRegistration not found: ' . $id);
        $entity->promoteFromWaitlist();
        $this->repository->save($entity, flush: true);
    }
}
