<?php

namespace App\Models\Content;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;
use App\Models\Cards\Deck;

class Article extends Model
{
    protected $table = 'articles';

    protected $fillable = ['title', 'slug', 'body', 'excerpt', 'cover_image_url', 'status', 'article_type', 'view_count', 'published_at', 'author_id', 'featured_deck_id'];

    protected $casts = [
        'published_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Draft', 'Published', 'Archived'];
    const ARTICLE_TYPE_VALUES = ['Guide', 'Tierlist', 'Matchup', 'News', 'Spotlight', 'Decklist'];

    public function author(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'author_id');
    }

    public function featuredDeck(): BelongsTo
    {
        return $this->belongsTo(Deck::class, 'featured_deck_id');
    }

    public function tagses(): BelongsToMany
    {
        return $this->belongsToMany(ArticleTag::class, 'article_tags_pivot', 'article_id', 'article_tag_id');
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->status === 'Published' && $this->published_at === null) {
            throw new \RuntimeException('Published article must have a published_at timestamp');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function publish(): void
    {
        throw new \RuntimeException('publish not implemented');
    }

    public function archive(): void
    {
        throw new \RuntimeException('archive not implemented');
    }

    public function incrementView(): void
    {
        throw new \RuntimeException('increment_view not implemented');
    }

    public function readingTimeMinutes(): int
    {
        throw new \RuntimeException('reading_time_minutes not implemented');
    }

}
