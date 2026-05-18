<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class AwardedPrize extends Model
{
    protected $table = 'awarded_prizes';

    protected $fillable = ['final_placement', 'awarded_at', 'claimed', 'claimed_at', 'prize_id', 'player_id'];

    protected $casts = [
        'awarded_at' => 'datetime',
        'claimed' => 'boolean',
        'claimed_at' => 'datetime',
    ];

    public function prize(): BelongsTo
    {
        return $this->belongsTo(TournamentPrize::class, 'prize_id');
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->final_placement === null || $this->final_placement > 0))) {
            $errors['final_placement_positive'] = 'Final placement must be greater than zero';
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
        if ($this->claimed === true && $this->claimed_at === null) {
            throw new \RuntimeException('Claimed prize must have a claimed_at timestamp');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function claim(): void
    {
        throw new \RuntimeException('claim not implemented');
    }

}
