<?php

namespace App\Http\Resources\Content;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ArticleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'body' => $this->body,
            'excerpt' => $this->excerpt,
            'cover_image_url' => $this->cover_image_url,
            'status' => $this->status,
            'article_type' => $this->article_type,
            'language' => $this->language,
            'view_count' => $this->view_count,
            'likes_count' => $this->likes_count,
            'is_featured' => $this->is_featured,
            'publishedAt' => $this->published_at,
            'createdAt' => $this->created_at,
            'updatedAt' => $this->updated_at,
            'author_id' => $this->author_id,
            'featured_deck_id' => $this->featured_deck_id,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
