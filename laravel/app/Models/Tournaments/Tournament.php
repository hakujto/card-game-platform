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

    protected $fillable = ['name', 'description', 'status', 'format', 'tournament_type', 'max_players', 'entry_fee', 'prize_pool', 'start_time', 'end_time', 'is_online', 'location', 'rules_text', 'season_id', 'organizer_id'];

    protected $casts = [
        'entry_fee' => 'decimal:2',
        'prize_pool' => 'decimal:2',
        'start_time' => 'datetime',
        'end_time' => 'datetime',
        'is_online' => 'boolean',
    ];

    const STATUS_VALUES = ['Draft', 'Registration', 'Ongoing', 'Completed', 'Cancelled'];
    const FORMAT_VALUES = ['Standard', 'Extended', 'Legacy', 'Vintage', 'Commander', 'Draft'];
    const TOURNAMENT_TYPE_VALUES = ['Swiss', 'SingleElimination', 'DoubleElimination', 'RoundRobin'];

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

    // ── Lifecycle state machine ──────────────────────────────────────
    const ALLOWED_TRANSITIONS = [
        'Draft' => ['Registration'],
        'Registration' => ['Ongoing', 'Cancelled'],
        'Ongoing' => ['Completed', 'Cancelled'],
    ];

    public function assertTransition(string $to): void
    {
        $allowed = static::ALLOWED_TRANSITIONS[$this->status] ?? [];
        if (!in_array($to, $allowed, true)) {
            throw new \InvalidArgumentException("Transition {$this->status} -> {$to} not allowed");
        }
    }

    // ── Business operations ──────────────────────────────────────────

    public function start(): void
    {
        // TODO: implement start
    }

    public function cancel(): void
    {
        // TODO: implement cancel
    }

    public function complete(): void
    {
        // TODO: implement complete
    }

    public function generateRound(): void
    {
        // TODO: implement generate_round
    }

    public function calculatePrizeDistribution(): ?string
    {
        // TODO: implement calculate_prize_distribution
        return null;
    }

    public function registerPlayer($player_id, $deck_id): void
    {
        // TODO: implement register_player
    }

    public function isFull(): ?bool
    {
        // TODO: implement is_full
        return null;
    }

    // ── Lifecycle hooks ──────────────────────────────────────────────
    protected static function boot(): void
    {
        parent::boot();
        static::updated(function (self $model) {
            $model->syncSeasonStats();
        });
    }

    protected function syncSeasonStats(): void
    {
        // TODO: implement sync_season_stats
    }

}
