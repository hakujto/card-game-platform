<?php

namespace App\Models\Players;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use App\Models\Tournaments\Season;

class PlayerSeasonStats extends Model
{
    protected $table = 'player_season_statses';

    protected $fillable = ['wins', 'losses', 'draws', 'tournament_wins', 'highest_rank', 'season_points', 'player_id', 'season_id'];

    const HIGHEST_RANK_VALUES = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond', 'Master', 'Grandmaster'];

    public function player(): BelongsTo
    {
        return $this->belongsTo(Player::class, 'player_id');
    }

    public function season(): BelongsTo
    {
        return $this->belongsTo(Season::class, 'season_id');
    }

    // ── Business operations ──────────────────────────────────────────

    public function winRate(): string
    {
        throw new \RuntimeException('win_rate not implemented');
    }

    public function addPoints($points): void
    {
        throw new \RuntimeException('add_points not implemented');
    }

    public function recordTournamentWin(): void
    {
        throw new \RuntimeException('record_tournament_win not implemented');
    }

}
