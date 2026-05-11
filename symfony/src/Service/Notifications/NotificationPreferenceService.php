<?php

namespace App\Service\Notifications;

use App\Entity\Notifications\NotificationPreference;
use App\Repository\Notifications\NotificationPreferenceRepository;

class NotificationPreferenceService
{
    public function __construct(
        private NotificationPreferenceRepository $repository,
    ) {}

    public function create(array $data): NotificationPreference
    {
        throw new \LogicException('Not implemented');
    }

    public function update(NotificationPreference $entity, array $data): NotificationPreference
    {
        throw new \LogicException('Not implemented');
    }
}
