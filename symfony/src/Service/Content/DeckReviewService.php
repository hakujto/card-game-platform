<?php

namespace App\Service\Content;

use App\Entity\Content\DeckReview;
use App\Repository\Content\DeckReviewRepository;

class DeckReviewService
{
    public function __construct(
        private DeckReviewRepository $repository,
    ) {}

    public function create(array $data): DeckReview
    {
        throw new \LogicException('Not implemented');
    }

    public function update(DeckReview $entity, array $data): DeckReview
    {
        throw new \LogicException('Not implemented');
    }
}
