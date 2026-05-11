<?php

namespace App\Service\Moderation;

use App\Entity\Moderation\ContentReport;
use App\Repository\Moderation\ContentReportRepository;

class ContentReportService
{
    public function __construct(
        private ContentReportRepository $repository,
    ) {}

    public function create(array $data): ContentReport
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ContentReport $entity, array $data): ContentReport
    {
        throw new \LogicException('Not implemented');
    }
}
