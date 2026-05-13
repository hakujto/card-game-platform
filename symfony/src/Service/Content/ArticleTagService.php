<?php

namespace App\Service\Content;

use App\Entity\Content\ArticleTag;
use App\Repository\Content\ArticleTagRepository;

class ArticleTagService
{
    public function __construct(
        private ArticleTagRepository $repository,
    ) {}

    public function create(array $data): ArticleTag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleTag $entity, array $data): ArticleTag
    {
        throw new \LogicException('Not implemented');
    }

}
