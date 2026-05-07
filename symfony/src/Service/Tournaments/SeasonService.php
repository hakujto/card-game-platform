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
}
