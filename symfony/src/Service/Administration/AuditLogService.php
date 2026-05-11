<?php

namespace App\Service\Administration;

use App\Entity\Administration\AuditLog;
use App\Repository\Administration\AuditLogRepository;

class AuditLogService
{
    public function __construct(
        private AuditLogRepository $repository,
    ) {}

    public function create(array $data): AuditLog
    {
        throw new \LogicException('Not implemented');
    }

    public function update(AuditLog $entity, array $data): AuditLog
    {
        throw new \LogicException('Not implemented');
    }
}
