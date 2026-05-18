<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;
use App\Models\Cards\Deck;

class TournamentRegistration extends Model
{
    protected $table = 'tournament_registrations';

    protected $fillable = ['status', 'seed', 'final_standing', 'points_earned', 'registered_at', 'tournament_id', 'player_id', 'deck_id'];

    protected $casts = [
        'registered_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Registered', 'Waitlisted', 'Withdrawn', 'Disqualified'];

    public function tournament(): BelongsTo
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function deck(): BelongsTo
    {
        return $this->belongsTo(Deck::class, 'deck_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->points_earned === null || $this->points_earned >= 0))) {
            $errors['points_earned_not_negative'] = 'Points earned must not be negative';
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
        if ($this->final_standing !== null && !(($this->final_standing === null || $this->final_standing > 0))) {
            throw new \RuntimeException('Final standing must be greater than zero');
        }
        if ($this->seed !== null && !(($this->seed === null || $this->seed > 0))) {
            throw new \RuntimeException('Seed must be greater than zero');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function withdraw(): void
    {
        throw new \RuntimeException('withdraw not implemented');
    }

    public function disqualify($reason): void
    {
        throw new \RuntimeException('disqualify not implemented');
    }

    public function promoteFromWaitlist(): void
    {
        throw new \RuntimeException('promote_from_waitlist not implemented');
    }

}
