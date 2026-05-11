<?php

namespace App\Service\Moderation;

use App\Entity\Moderation\ModerationAction;
use App\Repository\Moderation\ModerationActionRepository;

class ModerationActionService
{
    public function __construct(
        private ModerationActionRepository $repository,
    ) {}

    public function create(array $data): ModerationAction
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ModerationAction $entity, array $data): ModerationAction
    {
        throw new \LogicException('Not implemented');
    }
}
