<?php

namespace App\Service\Content;

use App\Entity\Content\DraftParticipant;
use App\Repository\Content\DraftParticipantRepository;

class DraftParticipantService
{
    public function __construct(
        private DraftParticipantRepository $repository,
    ) {}

    public function create(array $data): DraftParticipant
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftParticipant $entity, array $data): DraftParticipant
    {
        throw new \LogicException('Not implemented');
    }
}
