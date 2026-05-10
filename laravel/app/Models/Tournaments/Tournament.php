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

}
