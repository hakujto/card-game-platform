<?php

namespace App\Service\Cards;

use App\Entity\Cards\CardSet;
use App\Repository\Cards\CardSetRepository;

class CardSetService
{
    public function __construct(
        private CardSetRepository $repository,
    ) {}

    public function create(array $data): CardSet
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardSet $entity, array $data): CardSet
    {
        throw new \LogicException('Not implemented');
    }

}
