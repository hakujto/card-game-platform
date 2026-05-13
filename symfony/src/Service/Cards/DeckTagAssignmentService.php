<?php

namespace App\Service\Cards;

use App\Entity\Cards\DeckTagAssignment;
use App\Repository\Cards\DeckTagAssignmentRepository;

class DeckTagAssignmentService
{
    public function __construct(
        private DeckTagAssignmentRepository $repository,
    ) {}

    public function create(array $data): DeckTagAssignment
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckTagAssignment $entity, array $data): DeckTagAssignment
    {
        throw new \LogicException('Not implemented');
    }

}
