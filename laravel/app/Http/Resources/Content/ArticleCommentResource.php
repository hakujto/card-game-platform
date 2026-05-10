<?php

namespace App\Http\Resources\Content;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ArticleCommentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'body' => $this->body,
            'is_hidden' => $this->is_hidden,
            'created_at' => $this->created_at,
            'article_id' => $this->article_id,
            'author_id' => $this->author_id,
            'parent_comment_id' => $this->parent_comment_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
