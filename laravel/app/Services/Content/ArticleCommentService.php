<?php

namespace App\Services\Content;

use App\Models\Content\ArticleComment;

class ArticleCommentService
{
    public function create(array $data): ArticleComment
    {
        throw new \LogicException('Not implemented');
    }

    public function update(ArticleComment $articleComment, array $data): ArticleComment
    {
        throw new \LogicException('Not implemented');
    }
    public function hide(int $id): void
    {
        $articleComment = ArticleComment::findOrFail($id);
        $articleComment->hide();
        $articleComment->save();
    }

    public function unhide(int $id): void
    {
        $articleComment = ArticleComment::findOrFail($id);
        $articleComment->unhide();
        $articleComment->save();
    }

    public function isReply(int $id): bool
    {
        $articleComment = ArticleComment::findOrFail($id);
        $result = $articleComment->isReply();
        $articleComment->save();
        return $result;
    }
}
