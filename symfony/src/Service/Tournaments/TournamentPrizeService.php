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

}
