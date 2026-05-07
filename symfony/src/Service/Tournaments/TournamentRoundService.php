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
}
