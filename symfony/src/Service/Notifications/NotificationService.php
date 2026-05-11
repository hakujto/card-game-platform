<?php

namespace App\Service\Notifications;

use App\Entity\Notifications\Notification;
use App\Repository\Notifications\NotificationRepository;

class NotificationService
{
    public function __construct(
        private NotificationRepository $repository,
    ) {}

    public function create(array $data): Notification
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Notification $entity, array $data): Notification
    {
        throw new \LogicException('Not implemented');
    }
}
