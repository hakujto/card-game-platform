<?php

namespace App\Service\Moderation;

use App\Entity\Moderation\PlayerReport;
use App\Repository\Moderation\PlayerReportRepository;

class PlayerReportService
{
    public function __construct(
        private PlayerReportRepository $repository,
    ) {}

    public function create(array $data): PlayerReport
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlayerReport $entity, array $data): PlayerReport
    {
        throw new \LogicException('Not implemented');
    }
}
