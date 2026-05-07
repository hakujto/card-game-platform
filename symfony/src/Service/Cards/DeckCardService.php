<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckCard;
use App\Repository\Cards\DeckCardRepository;

class DeckCardService
{
    public function __construct(
        private DeckCardRepository $repository,
    ) {}

    public function create(array $data): DeckCard
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckCard $entity, array $data): DeckCard
    {
        throw new \LogicException('Not implemented');
    }
}
