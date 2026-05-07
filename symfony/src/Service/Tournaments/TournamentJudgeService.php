<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\TournamentJudge;
use App\Repository\Tournaments\TournamentJudgeRepository;

class TournamentJudgeService
{
    public function __construct(
        private TournamentJudgeRepository $repository,
    ) {}

    public function create(array $data): TournamentJudge
    {
        throw new \LogicException('Not implemented');
    }

    public function update(TournamentJudge $entity, array $data): TournamentJudge
    {
        throw new \LogicException('Not implemented');
    }
}
