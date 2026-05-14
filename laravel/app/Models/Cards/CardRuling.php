<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class CardRuling extends Model
{
    protected $table = 'card_rulings';

    protected $fillable = ['ruling_text', 'published_at', 'source', 'card_id'];

    protected $casts = [
        'published_at' => 'date',
    ];

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    // ── Business operations ──────────────────────────────────────────

    public function isCurrent(): bool
    {
        throw new \RuntimeException('is_current not implemented');
    }

    public function supersedesPrevious(): bool
    {
        throw new \RuntimeException('supersedes_previous not implemented');
    }

}
