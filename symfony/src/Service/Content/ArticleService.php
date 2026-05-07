<?php

namespace App\Service\Content;

use App\Entity\Content\Article;
use App\Repository\Content\ArticleRepository;

class ArticleService
{
    public function __construct(
        private ArticleRepository $repository,
    ) {}

    public function create(array $data): Article
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Article $entity, array $data): Article
    {
        throw new \LogicException('Not implemented');
    }
}
