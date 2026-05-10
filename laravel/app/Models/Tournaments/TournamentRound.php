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

}
