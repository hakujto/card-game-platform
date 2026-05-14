<?php

namespace App\Models\Cards;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class CardAbility extends Model
{
    protected $table = 'card_abilities';

    protected $fillable = ['ability_type', 'keyword', 'ability_text', 'timing', 'card_id'];

    const ABILITY_TYPE_VALUES = ['Keyword', 'Activated', 'Triggered', 'Static'];
    const TIMING_VALUES = ['Any', 'Sorcery', 'Instant', 'Combat'];

    public function card(): BelongsTo
    {
        return $this->belongsTo(Card::class, 'card_id');
    }

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->ability_type === 'Keyword' && $this->keyword === null) {
            throw new \RuntimeException('Keyword ability must have a keyword name');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function isUsableAt($timing): bool
    {
        throw new \RuntimeException('is_usable_at not implemented');
    }

    public function describe(): string
    {
        throw new \RuntimeException('describe not implemented');
    }

}
