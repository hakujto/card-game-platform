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
    public function publish(int $id): void
    {
        $article = Article::findOrFail($id);
        $article->publish();
        $article->save();
    }

    public function archive(int $id): void
    {
        $article = Article::findOrFail($id);
        $article->archive();
        $article->save();
    }

    public function incrementView(int $id): void
    {
        $article = Article::findOrFail($id);
        $article->incrementView();
        $article->save();
    }

    public function readingTimeMinutes(int $id): int
    {
        $article = Article::findOrFail($id);
        $result = $article->readingTimeMinutes();
        $article->save();
        return $result;
    }
}
