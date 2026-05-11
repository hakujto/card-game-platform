<?php

namespace App\Service\Administration;

use App\Entity\Administration\PlatformConfig;
use App\Repository\Administration\PlatformConfigRepository;

class PlatformConfigService
{
    public function __construct(
        private PlatformConfigRepository $repository,
    ) {}

    public function create(array $data): PlatformConfig
    {
        throw new \LogicException('Not implemented');
    }

    public function update(PlatformConfig $entity, array $data): PlatformConfig
    {
        throw new \LogicException('Not implemented');
    }
}
