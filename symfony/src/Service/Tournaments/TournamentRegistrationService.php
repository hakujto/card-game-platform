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
}
