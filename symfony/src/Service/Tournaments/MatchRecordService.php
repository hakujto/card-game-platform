<?php

namespace App\Service\Tournaments;

use App\Entity\Tournaments\MatchRecord;
use App\Repository\Tournaments\MatchRecordRepository;

class MatchRecordService
{
    public function __construct(
        private MatchRecordRepository $repository,
    ) {}

    public function create(array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }

    public function update(MatchRecord $entity, array $data): MatchRecord
    {
        throw new \LogicException('Not implemented');
    }
}
