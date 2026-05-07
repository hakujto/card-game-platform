<?php

namespace App\Service\Content;

use App\Entity\Content\ArticleComment;
use App\Repository\Content\ArticleCommentRepository;

class ArticleCommentService
{
    public function __construct(
        private ArticleCommentRepository $repository,
    ) {}

    public function create(array $data): ArticleComment
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleComment $entity, array $data): ArticleComment
    {
        throw new \LogicException('Not implemented');
    }
}
