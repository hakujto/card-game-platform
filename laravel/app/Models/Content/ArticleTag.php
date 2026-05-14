<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class ArticleTag extends Model
{
    protected $table = 'article_tags';

    protected $fillable = ['name', 'slug'];

    // ── Business operations ──────────────────────────────────────────

    public function rename($new_name): void
    {
        throw new \RuntimeException('rename not implemented');
    }

    public function articleCount(): int
    {
        throw new \RuntimeException('article_count not implemented');
    }

}
