<?php

namespace App\Service\Content;

use App\Entity\Content\ArticleTagAssignment;
use App\Repository\Content\ArticleTagAssignmentRepository;

class ArticleTagAssignmentService
{
    public function __construct(
        private ArticleTagAssignmentRepository $repository,
    ) {}

    public function create(array $data): ArticleTagAssignment
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleTagAssignment $entity, array $data): ArticleTagAssignment
    {
        throw new \LogicException('Not implemented');
    }
}
