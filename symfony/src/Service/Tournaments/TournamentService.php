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
}
