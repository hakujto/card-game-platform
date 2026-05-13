<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckSideboardCard;
use App\Repository\Cards\DeckSideboardCardRepository;

class DeckSideboardCardService
{
    public function __construct(
        private DeckSideboardCardRepository $repository,
    ) {}

    public function create(array $data): DeckSideboardCard
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckSideboardCard $entity, array $data): DeckSideboardCard
    {
        throw new \LogicException('Not implemented');
    }

}
