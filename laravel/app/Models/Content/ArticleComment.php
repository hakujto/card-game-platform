<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class ArticleComment extends Model
{
    protected $table = 'article_comments';

    protected $fillable = ['body', 'is_hidden', 'article_id', 'author_id', 'parent_comment_id'];

    protected $casts = [
        'is_hidden' => 'boolean',
    ];

    public function article(): BelongsTo
    {
        return $this->belongsTo(Article::class, 'article_id');
    }

    public function author(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'author_id');
    }

    public function parentComment(): BelongsTo
    {
        return $this->belongsTo(ArticleComment::class, 'parent_comment_id');
    }

}
