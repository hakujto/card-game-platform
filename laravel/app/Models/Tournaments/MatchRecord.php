<?php

namespace App\Models\Tournaments;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Players\Player;

class MatchRecord extends Model
{
    protected $table = 'matches';

    protected $fillable = ['table_number', 'status', 'player1_wins', 'player2_wins', 'started_at', 'ended_at', 'result_notes', 'round_id', 'player1_id', 'player2_id'];

    protected $casts = [
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
    ];

    const STATUS_VALUES = ['Pending', 'Active', 'Completed', 'BYE', 'Draw'];

    public function round(): BelongsTo
    {
        return $this->belongsTo(TournamentRound::class, 'round_id');
    }

    public function player1(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player1_id');
    }

    public function player2(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player2_id');
    }

}
