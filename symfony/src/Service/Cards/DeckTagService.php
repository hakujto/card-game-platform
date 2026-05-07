<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckTag;
use App\Repository\Cards\DeckTagRepository;

class DeckTagService
{
    public function __construct(
        private DeckTagRepository $repository,
    ) {}

    public function create(array $data): DeckTag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckTag $entity, array $data): DeckTag
    {
        throw new \LogicException('Not implemented');
    }
}
