<?php

namespace App\Service\Cards;

use App\Entity\Cards\Card;
use App\Repository\Cards\CardRepository;

class CardService
{
    public function __construct(
        private CardRepository $repository,
    ) {}

    public function create(array $data): Card
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Card $entity, array $data): Card
    {
        throw new \LogicException('Not implemented');
    }
}
