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

}
