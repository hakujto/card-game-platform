<?php

namespace App\Service\Cards;

use App\Entity\Cards\CardRuling;
use App\Repository\Cards\CardRulingRepository;

class CardRulingService
{
    public function __construct(
        private CardRulingRepository $repository,
    ) {}

    public function create(array $data): CardRuling
    {
        throw new \LogicException('Not implemented');
    }

    public function update(CardRuling $entity, array $data): CardRuling
    {
        throw new \LogicException('Not implemented');
    }
}
