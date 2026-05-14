<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class Tournament extends Model
{
    protected $table = 'tournaments';

    protected $fillable = ['name', 'description', 'format', 'tournament_type', 'status', 'max_players', 'entry_fee', 'prize_pool', 'start_time', 'end_time', 'is_online', 'location', 'rules_text', 'season_id', 'organizer_id'];

    protected $casts = [
        'entry_fee' => 'decimal:2',
        'prize_pool' => 'decimal:2',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'is_online' => 'boolean',
    ];

    const FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];
    const TOURNAMENT_TYPE_VALUES = ['Swiss', 'SingleElimination', 'DoubleElimination', 'RoundRobin'];
    const STATUS_VALUES = ['Draft', 'Registration', 'Ongoing', 'Completed', 'Cancelled'];

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class, 'season_id');
    }

    public function organizer(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'organizer_id');
    }

    public function judgeses(): BelongsToMany
    {
        return $this->belongsToMany(Player::class, 'tournament_judges_pivot', 'tournament_id', 'player_id');
    }

    // ── Validation rules ─────────────────────────────────────────────
    public function validateRules(): void
    {
        $errors = [];
        if (!(($this->max_players === null || ($this->max_players >= 2 && $this->max_players <= 512)))) {
            $errors['max_players_positive'] = 'Tournament must allow between 2 and 512 players';
        }
        if (!(($this->entry_fee === null || (float)$this->entry_fee >= (float)0))) {
            $errors['entry_fee_not_negative'] = 'Entry fee must not be negative';
        }
        if (!(($this->prize_pool === null || (float)$this->prize_pool >= (float)0))) {
            $errors['prize_pool_not_negative'] = 'Prize pool must not be negative';
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
        if ($this->end_time !== null && !(($this->end_time === null || ($this->start_time !== null && $this->end_time > $this->start_time)))) {
            throw new \RuntimeException('End time must be after start time');
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        throw new \RuntimeException('start not implemented');
    }

    public function cancel(): void
    {
        throw new \RuntimeException('cancel not implemented');
    }

    public function complete(): void
    {
        throw new \RuntimeException('complete not implemented');
    }

    public function generateRound(): void
    {
        throw new \RuntimeException('generate_round not implemented');
    }

    public function calculatePrizeDistribution(): string
    {
        throw new \RuntimeException('calculate_prize_distribution not implemented');
    }

    public function isFull(): bool
    {
        throw new \RuntimeException('is_full not implemented');
    }

}
