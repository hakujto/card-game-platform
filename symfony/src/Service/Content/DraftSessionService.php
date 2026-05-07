<?php

namespace App\Service\Content;

use App\Entity\Content\DraftSession;
use App\Repository\Content\DraftSessionRepository;

class DraftSessionService
{
    public function __construct(
        private DraftSessionRepository $repository,
    ) {}

    public function create(array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DraftSession $entity, array $data): DraftSession
    {
        throw new \LogicException('Not implemented');
    }
}
