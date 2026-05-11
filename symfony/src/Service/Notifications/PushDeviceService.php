<?php

namespace App\Service\Notifications;

use App\Entity\Notifications\PushDevice;
use App\Repository\Notifications\PushDeviceRepository;

class PushDeviceService
{
    public function __construct(
        private PushDeviceRepository $repository,
    ) {}

    public function create(array $data): PushDevice
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PushDevice $entity, array $data): PushDevice
    {
        throw new \LogicException('Not implemented');
    }
}
