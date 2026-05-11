<?php

namespace App\Service\Administration;

use App\Entity\Administration\FeatureFlag;
use App\Repository\Administration\FeatureFlagRepository;

class FeatureFlagService
{
    public function __construct(
        private FeatureFlagRepository $repository,
    ) {}

    public function create(array $data): FeatureFlag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(FeatureFlag $entity, array $data): FeatureFlag
    {
        throw new \LogicException('Not implemented');
    }
}
