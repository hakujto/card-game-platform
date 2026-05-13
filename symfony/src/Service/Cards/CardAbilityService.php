<?php

namespace App\Service\Cards;

use App\Entity\Cards\CardAbility;
use App\Repository\Cards\CardAbilityRepository;

class CardAbilityService
{
    public function __construct(
        private CardAbilityRepository $repository,
    ) {}

    public function create(array $data): CardAbility
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardAbility $entity, array $data): CardAbility
    {
        throw new \LogicException('Not implemented');
    }

}
