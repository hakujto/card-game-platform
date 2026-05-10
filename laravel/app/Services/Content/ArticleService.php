<?php

namespace App\Services\Content;

use App\Models\Content\Article;

class ArticleService
{
    public function create(array $data): Article
    {
        throw new \LogicException('Not implemented');
    }

    public function update(Article $article, array $data): Article
    {
        throw new \LogicException('Not implemented');
    }
}
