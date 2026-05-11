<?php

namespace App\Service\Administration;

use App\Entity\Administration\SystemAnnouncement;
use App\Repository\Administration\SystemAnnouncementRepository;

class SystemAnnouncementService
{
    public function __construct(
        private SystemAnnouncementRepository $repository,
    ) {}

    public function create(array $data): SystemAnnouncement
    {
        throw new \LogicException('Not implemented');
    }

    public function update(SystemAnnouncement $entity, array $data): SystemAnnouncement
    {
        throw new \LogicException('Not implemented');
    }
}
