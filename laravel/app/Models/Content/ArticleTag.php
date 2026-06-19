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

    public function articleAssignments(): HasMany
    {
        return $this->hasMany(ArticleTagAssignment::class, 'tag_id');
    }

    // ── Business operations ──────────────────────────────────────────

    public function rename($new_name): void
    {
        // TODO: implement rename
    }

    public function articleCount(): ?int
    {
        // TODO: implement article_count
        return null;
    }

}
