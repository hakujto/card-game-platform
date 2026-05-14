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

    // ── Domain invariants (IMPLIES rules) ───────────────────────────────
    public function validateImplies(): void
    {
        if ($this->ended_at !== null && !(($this->ended_at === null || ($this->started_at !== null && $this->ended_at > $this->started_at)))) {
            throw new \RuntimeException('Round end time must be after start time');
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
