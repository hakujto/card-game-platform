<?php

namespace App\Services\Content;

use App\Models\Content\ArticleTag;

class ArticleTagService
{
    public function create(array $data): ArticleTag
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleTag $articleTag, array $data): ArticleTag
    {
        throw new \LogicException('Not implemented');
    }
    public function rename(int $id, $new_name): void
    {
        $articleTag = ArticleTag::findOrFail($id);
        $articleTag->rename($new_name);
        $articleTag->save();
    }

    public function articleCount(int $id): int
    {
        $articleTag = ArticleTag::findOrFail($id);
        $result = $articleTag->articleCount();
        $articleTag->save();
        return $result;
    }
}
