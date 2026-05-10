<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class ArticleTagAssignment extends Model
{
    protected $table = 'article_tag_assignments';

    protected $fillable = ['article_id', 'tag_id'];

    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class, 'article_id');
    }

    public function tag(): BelongsTo
    {
        return $this->belongsTo(ArticleTag::class, 'tag_id');
    }

}
