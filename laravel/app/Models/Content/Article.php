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

    protected $fillable = ['title', 'slug', 'body', 'excerpt', 'cover_image_url', 'status', 'article_type', 'language', 'view_count', 'likes_count', 'total_views_alltime', 'is_featured', 'published_at', 'author_id', 'featured_deck_id'];

    protected $casts = [
        'is_featured' => 'boolean',
        'published_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Draft', 'Published', 'Archived'];
    const ARTICLE_TYPE_VALUES = ['Guide', 'Tierlist', 'Matchup', 'News', 'Spotlight', 'Decklist'];
    const LANGUAGE_VALUES = ['EN', 'DE', 'FR', 'IT', 'ES', 'JP', 'PT'];

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
        return $this->belongsToMany(ArticleTag::class, 'article_tag_assignments', 'article_id', 'article_tag_id')->using(ArticleTagAssignment::class);
    }

    public function tagAssignments(): HasMany
    {
        return $this->hasMany(ArticleTagAssignment::class, 'article_id');
    }

    public function comments(): HasMany
    {
        return $this->hasMany(ArticleComment::class, 'article_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->view_count === null || $this->view_count >= 0))) {
            $errors['view_count_not_negative'] = 'Article view count must not be negative';
        }
        if (!(($this->likes_count === null || $this->likes_count >= 0))) {
            $errors['likes_count_not_negative'] = 'Article likes count must not be negative';
        }
        if (!empty($errors)) {
            throw new \Illuminate\Validation\ValidationException(
                \Illuminate\Support\Facades\Validator::make([], []),
                response()->json(['errors' => $errors], 422)
            );
        }
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->status === 'Published' && $this->published_at === null) {
            throw new \RuntimeException('Published article must have a published_at timestamp');
        }
    }

    // ── Lifecycle state machine ──────────────────────────────────────
    const ALLOWED_TRANSITIONS = [
        'Draft' => ['Published'],
        'Published' => ['Archived'],
        'Archived' => ['Draft'],
    ];

    public function assertTransition(string $to): void
    {
        $allowed = static::ALLOWED_TRANSITIONS[$this->status] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \InvalidArgumentException("Transition {$this->status} -> {$to} not allowed");
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function publish(): void
    {
        // TODO: implement publish
    }

    public function archive(): void
    {
        // TODO: implement archive
    }

    public function replace($data): ?bool
    {
        // TODO: implement replace
        return null;
    }

    public function incrementView(): void
    {
        // TODO: implement increment_view
    }

    public function like(): void
    {
        // TODO: implement like
    }

    public function unlike(): void
    {
        // TODO: implement unlike
    }

    public function readingTimeMinutes(): ?int
    {
        // TODO: implement reading_time_minutes
        return null;
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    protected static function boot(): void
    {
        parent::boot();
        static::saved(function (self $model) {
            $model->updateSearchIndex();
        });
    }

    protected function updateSearchIndex(): void
    {
        // TODO: implement update_search_index
    }

}
