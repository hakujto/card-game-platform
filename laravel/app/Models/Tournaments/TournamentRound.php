<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class TournamentRound extends Model
{
    protected $table = 'tournament_rounds';

    protected $fillable = ['round_number', 'status', 'started_at', 'ended_at', 'time_limit_minutes', 'tournament_id'];

    protected $casts = [
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Pending', 'Active', 'Completed'];

    public function tournament(): BelongsTo
    {
        return $this->belongsTo(Tournament::class, 'tournament_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->round_number === null || $this->round_number > 0))) {
            $errors['round_number_positive'] = 'Round number must be greater than zero';
        }
        if (!(($this->time_limit_minutes === null || $this->time_limit_minutes > 0))) {
            $errors['time_limit_positive'] = 'Round time limit must be greater than zero';
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
        if ($this->ended_at !== null && !(($this->ended_at === null || ($this->started_at !== null && $this->ended_at > $this->started_at)))) {
            throw new \RuntimeException('Round end time must be after start time');
        }
        if ($this->status === 'Completed' && $this->started_at === null) {
            throw new \RuntimeException('Completed round must have a start time');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        throw new \RuntimeException('start not implemented');
    }

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function generatePairings(): void
    {
        throw new \RuntimeException('generate_pairings not implemented');
    }

    public function isTimeExpired(): bool
    {
        throw new \RuntimeException('is_time_expired not implemented');
    }

}
