<?php

namespace App\Service\Cards;

use App\Entity\Cards\Deck;
use App\Repository\Cards\DeckRepository;

class DeckService
{
    public function __construct(
        private DeckRepository $repository,
    ) {}

    public function create(array $data): Deck
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Deck $entity, array $data): Deck
    {
        throw new \LogicException('Not implemented');
    }
}
